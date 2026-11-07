require 'digest'
require 'fileutils'
require 'securerandom'

# Users created through /api/users, one file per user in a directory. Every puma
# worker on the machine reads the same directory, so a user created by one worker
# can log in through another.
#
# - Writes hold a lock (a Mutex for threads, flock for processes), so two requests
#   creating the same username at once give one :created and one :exists.
# - A user expires `ttl` seconds after it is created (the file's mtime) and is then
#   treated as not found.
# - At `max_users`, creating a user first drops the oldest ones.
# - Passwords are stored as a salted SHA-256.
class UserStore
  # Not only dots: "." and ".." can't be used in /api/users/:username.
  USERNAME = /\A(?!\.+\z)[A-Za-z0-9_.-]{1,64}\z/
  MAX_PASSWORD_LENGTH = 128

  def initialize(dir:, ttl: 60 * 60, max_users: 10_000, clock: -> { Time.now })
    @dir = dir
    @ttl = ttl
    @max_users = max_users
    @clock = clock
    @mutex = Mutex.new
    FileUtils.mkdir_p(dir)
  end

  # :created, or :exists when the username is taken.
  def create(username, password)
    raise ArgumentError, 'invalid username' unless valid_username?(username)

    salt = SecureRandom.hex(16)
    record = "#{salt}:#{digest(salt, password)}"
    locked do
      return :exists if find(username)

      prune(@max_users - 1)
      path = path_for(username)
      tmp = "#{path}.#{SecureRandom.hex(4)}.tmp"
      File.write(tmp, record)
      created_at = @clock.call
      File.utime(created_at, created_at, tmp)
      File.rename(tmp, path)
    end
    :created
  end

  # true when the user was deleted, false when there is no such user.
  def delete(username)
    locked do
      return false unless find(username)

      File.delete(path_for(username))
      true
    end
  end

  def exists?(username)
    !find(username).nil?
  end

  # :ok, :wrong_password, or :not_found.
  def authenticate(username, password)
    record = find(username)
    return :not_found unless record

    salt, hash = record.split(':', 2)
    Rack::Utils.secure_compare(digest(salt, password.to_s), hash.to_s) ? :ok : :wrong_password
  end

  def count
    user_files.size
  end

  private

  def valid_username?(username)
    username.is_a?(String) && USERNAME.match?(username)
  end

  # The stored "salt:hash", or nil when there is no such user or it expired.
  def find(username)
    return nil unless valid_username?(username)

    path = path_for(username)
    return nil if expired?(File.mtime(path))

    File.read(path)
  rescue Errno::ENOENT
    nil
  end

  def expired?(created_at)
    @clock.call - created_at >= @ttl
  end

  def digest(salt, password)
    Digest::SHA256.hexdigest("#{salt}#{password}")
  end

  # Hex keeps names like "." or ".." safe and case-sensitive on any file system.
  def path_for(username)
    File.join(@dir, "u-#{username.unpack1('H*')}")
  end

  def user_files
    Dir.children(@dir).filter_map do |name|
      File.join(@dir, name) if name.start_with?('u-') && !name.end_with?('.tmp')
    end
  end

  # Keeps at most `keep` users: expired ones go first, then the oldest.
  def prune(keep)
    files = user_files
    return if files.size <= keep

    by_age = files.filter_map { |path| [path, File.mtime(path)] rescue nil }.sort_by(&:last)
    expired, live = by_age.partition { |_, created_at| expired?(created_at) }
    doomed = expired + live.first([live.size - keep, 0].max)
    doomed.each { |path, _| File.delete(path) rescue nil }
  end

  def locked
    @mutex.synchronize do
      File.open(File.join(@dir, '.lock'), File::RDWR | File::CREAT) do |lock|
        lock.flock(File::LOCK_EX)
        yield
      end
    end
  end
end
