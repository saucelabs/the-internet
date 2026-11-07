# In-process tests of the users store and the login flow, with a clock the
# tests move forward, so expiry can be checked without waiting an hour.
#
#   bundle exec rake unit
ENV['RACK_ENV'] = 'test'
require 'rack/mock'
require 'tmpdir'
require_relative '../../server'

describe UserStore do
  let(:dir) { Dir.mktmpdir('api_users') }
  let(:now) { [Time.now] }
  let(:store) { UserStore.new(dir: dir, ttl: 60, max_users: 3, clock: -> { now[0] }) }

  after { FileUtils.rm_rf(dir) }

  def later(seconds)
    now[0] += seconds
  end

  it 'creates, authenticates and deletes a user' do
    expect(store.create('alice', 'pw')).to eq :created
    expect(store.create('alice', 'other')).to eq :exists
    expect(store.authenticate('alice', 'pw')).to eq :ok
    expect(store.authenticate('alice', 'nope')).to eq :wrong_password
    expect(store.delete('alice')).to be true
    expect(store.delete('alice')).to be false
    expect(store.authenticate('alice', 'pw')).to eq :not_found
  end

  it 'keeps usernames case-sensitive' do
    store.create('Alice', 'pw')
    expect(store.create('alice', 'pw')).to eq :created
  end

  it 'stores a salted hash, not the password' do
    store.create('alice', 'my-password')
    store.create('bob', 'my-password')
    records = Dir.children(dir).grep(/\Au-/).map { |f| File.read(File.join(dir, f)) }
    expect(records.join).not_to include 'my-password'
    expect(records.uniq.size).to eq 2
  end

  it 'treats an expired user as not found' do
    store.create('alice', 'pw')
    later(59)
    expect(store.exists?('alice')).to be true
    later(1)
    expect(store.exists?('alice')).to be false
    expect(store.authenticate('alice', 'pw')).to eq :not_found
    expect(store.delete('alice')).to be false
    expect(store.create('alice', 'new')).to eq :created
    expect(store.authenticate('alice', 'new')).to eq :ok
  end

  it 'drops the oldest users at the cap' do
    %w[a b c].each { |name| store.create(name, 'pw'); later(1) }
    store.create('d', 'pw')
    expect(store.count).to eq 3
    expect(%w[a b c d].map { |name| store.exists?(name) }).to eq [false, true, true, true]
  end

  it 'drops expired users before live ones' do
    store.create('old', 'pw')
    later(61)
    store.create('b', 'pw')
    store.create('c', 'pw')
    store.create('d', 'pw')
    expect(%w[b c d].map { |name| store.exists?(name) }).to all(be true)
  end

  it 'rejects unsafe usernames' do
    ['', '.', '..', 'a/b', 'a' * 65, nil].each do |name|
      expect { store.create(name, 'pw') }.to raise_error(ArgumentError)
      expect(store.exists?(name)).to be false
    end
  end

  it 'creates the same username once when threads race' do
    big = UserStore.new(dir: dir)
    results = Array.new(20) { Thread.new { big.create('same', 'pw') } }.map(&:value)
    expect(results.count(:created)).to eq 1
  end

  it 'creates the same username once when processes race' do
    big = UserStore.new(dir: dir)
    readers = Array.new(6) do
      r, w = IO.pipe
      fork { r.close; w.write(big.create('same', 'pw')); w.close; exit!(0) }
      w.close
      r
    end
    Process.waitall
    expect(readers.map(&:read).count('created')).to eq 1
  end
end

describe 'Login with API users' do
  let(:dir) { Dir.mktmpdir('api_users') }
  let(:now) { [Time.now] }

  before do
    @cookie = nil
    Public.set :user_store, UserStore.new(dir: dir, ttl: 3600, clock: -> { now[0] })
  end

  after { FileUtils.rm_rf(dir) }

  def request(method, path, **opts)
    opts['HTTP_COOKIE'] = @cookie if @cookie
    res = Rack::MockRequest.new(Public).request(method, path, opts)
    cookie = Array(res.headers['set-cookie']).join("\n")[/rack\.session=[^;]+/]
    @cookie = cookie if cookie
    res
  end

  def create(username, password)
    request('POST', '/api/users', input: JSON.generate(username: username, password: password))
  end

  def login(username, password)
    request('POST', '/authenticate', params: { username: username, password: password })
  end

  it 'logs in a created user and shows the username' do
    expect(create('alice', 'pw').status).to eq 201
    expect(login('alice', 'pw').location).to end_with '/secure'
    expect(request('GET', '/secure').body).to include '<span id="username">alice</span>'
  end

  it "an expired user can't log in" do
    create('alice', 'pw')
    now[0] += 3600
    expect(login('alice', 'pw').location).to end_with '/login'
    expect(request('GET', '/login').body).to include 'Your username is invalid!'
  end

  it 'logs out a browser when its user expires' do
    create('alice', 'pw')
    login('alice', 'pw')
    expect(request('GET', '/secure').status).to eq 200
    now[0] += 3600
    expect(request('GET', '/secure').location).to end_with '/login'
  end
end
