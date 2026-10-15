require 'net/http'
require 'uri'

# Minimal HTTP client with a cookie jar, so specs can follow session flows
# (login, flash messages, A/B cookies) against any deployment.
class Client
  attr_reader :cookies

  def initialize(base_url)
    @base = URI(base_url)
    @cookies = {}
  end

  def get(path, headers = {})
    request(Net::HTTP::Get.new(path, headers))
  end

  def post(path, form = {}, headers = {})
    req = Net::HTTP::Post.new(path, headers)
    req.set_form_data(form)
    request(req)
  end

  def post_multipart(path, fields)
    req = Net::HTTP::Post.new(path)
    req.set_form(fields, 'multipart/form-data')
    request(req)
  end

  def request(req, attempts: 3)
    req['Cookie'] = @cookies.map { |k, v| "#{k}=#{v}" }.join('; ') unless @cookies.empty?
    res = nil
    attempts.times do |i|
      last = i == attempts - 1
      begin
        res = Net::HTTP.start(@base.host, @base.port, use_ssl: @base.scheme == 'https',
                              read_timeout: 30) { |http| http.request(req) }
      rescue Net::OpenTimeout, Net::ReadTimeout
        raise if last

        next sleep(2)
      end
      # Heroku occasionally answers 503 while a dyno wakes up.
      break unless res.code == '503' && res['server'] == 'Heroku' && !last
      sleep 2
    end
    store_cookies(res)
    res
  end

  # Follows a redirect within the same deployment.
  def follow(res)
    get(URI(res['location']).request_uri)
  end

  private

  def store_cookies(res)
    Array(res.get_fields('set-cookie')).each do |line|
      name, value = line.split(';').first.split('=', 2)
      @cookies[name.strip] = value.to_s
    end
  end
end
