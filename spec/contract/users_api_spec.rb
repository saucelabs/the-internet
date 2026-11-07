require_relative 'spec_helper'
require 'json'
require 'securerandom'

describe 'Users API', :writes, :unreleased do
  def unique_name
    "user-#{SecureRandom.hex(6)}"
  end

  def api(method, path, body = nil, http = client)
    req = Net::HTTP.const_get(method.capitalize).new(path, 'Content-Type' => 'application/json')
    req.body = body.is_a?(String) ? body : JSON.generate(body) if body
    http.request(req)
  end

  def create(username, password = 'secret', http = client)
    api(:post, '/api/users', { username: username, password: password }, http)
  end

  def json(res)
    JSON.parse(res.body)
  end

  def login(username, password, http = client)
    http.post('/authenticate', username: username, password: password)
  end

  def secure_username(http = client)
    html(http.get('/secure')).at_css('#username')&.text
  end

  def flash(res)
    html(res).at_css('#flash-messages #flash').text
  end

  describe 'POST /api/users' do
    it 'creates a user (201)' do
      name = unique_name
      res = create(name)
      expect(res.code).to eq '201'
      expect(res['content-type']).to include 'application/json'
      expect(json(res)).to eq('username' => name)
    end

    it 'answers 409 for an existing username, and for tomsmith' do
      name = unique_name
      create(name)
      [name, 'tomsmith'].each do |taken|
        res = create(taken)
        expect(res.code).to eq '409'
        expect(json(res)['error']).to be_a String
      end
    end

    {
      'invalid JSON' => 'not json',
      'a JSON array' => '[1]',
      'a missing username' => { password: 'x' },
      'an empty username' => { username: '', password: 'x' },
      'a missing password' => { username: 'someone' },
      'an empty password' => { username: 'someone', password: '' },
      'a username over 64 characters' => { username: 'a' * 65, password: 'x' },
      'a username with a space' => { username: 'a b', password: 'x' },
      'a username with a slash' => { username: 'a/b', password: 'x' },
      'a username of only dots' => { username: '..', password: 'x' },
      'a username that is not a string' => { username: 12, password: 'x' },
      'a password over 128 characters' => { username: 'someone', password: 'p' * 129 }
    }.each do |what, body|
      it "answers 400 for #{what}" do
        res = api(:post, '/api/users', body)
        expect(res.code).to eq '400'
        expect(json(res)['error']).to be_a String
      end
    end

    it 'accepts the longest username and password' do
      name = "#{unique_name}-#{'a' * 64}"[0, 64]
      expect(create(name, 'p' * 128).code).to eq '201'
      api(:delete, "/api/users/#{name}")
    end
  end

  describe 'logging in' do
    it 'logs in a created user through the form and shows the username on /secure' do
      name = unique_name
      create(name, 'pa55')
      res = login(name, 'pa55')
      expect(path_of(res['location'])).to eq '/secure'
      secure = client.follow(res)
      expect(flash(secure)).to include 'You logged into a secure area!'
      expect(html(secure).at_css('#username').text).to eq name
    end

    it 'keeps the form messages for a wrong password and an unknown user' do
      name = unique_name
      create(name, 'pa55')
      expect(flash(client.follow(login(name, 'nope')))).to include 'Your password is invalid!'
      expect(flash(client.follow(login(unique_name, 'pa55')))).to include 'Your username is invalid!'
    end

    it 'shows tomsmith on /secure' do
      login('tomsmith', 'SuperSecretPassword!')
      expect(secure_username).to eq 'tomsmith'
    end
  end

  describe 'DELETE /api/users/:username' do
    it 'deletes a user (204), then answers 404' do
      name = unique_name
      create(name)
      res = api(:delete, "/api/users/#{name}")
      expect(res.code).to eq '204'
      expect(res.body.to_s).to eq ''
      expect(api(:delete, "/api/users/#{name}").code).to eq '404'
    end

    it 'answers 404 for a user that never existed' do
      expect(api(:delete, "/api/users/#{unique_name}").code).to eq '404'
    end

    it "answers 403 for tomsmith, who keeps working" do
      expect(api(:delete, '/api/users/tomsmith').code).to eq '403'
      login('tomsmith', 'SuperSecretPassword!')
      expect(secure_username).to eq 'tomsmith'
    end

    it "a deleted user can't log in" do
      name = unique_name
      create(name)
      api(:delete, "/api/users/#{name}")
      expect(flash(client.follow(login(name, 'secret')))).to include 'Your username is invalid!'
    end

    it 'logs out a browser of a deleted user on the next visit to /secure' do
      name = unique_name
      create(name)
      login(name, 'secret')
      expect(secure_username).to eq name
      api(:delete, "/api/users/#{name}")
      res = client.get('/secure')
      expect(path_of(res['location'])).to eq '/login'
      expect(flash(client.follow(res))).to include 'You must login to view the secure area!'
    end
  end

  describe 'POST /api/sessions' do
    it 'answers 200 with the session cookie of the form, which opens /secure' do
      name = unique_name
      create(name)
      res = api(:post, '/api/sessions', { username: name, password: 'secret' }, Client.new(BASE_URL))
      expect(res.code).to eq '200'
      expect(json(res)).to eq('username' => name)
      cookie = res['set-cookie'][/rack\.session=[^;]+/]
      expect(cookie).not_to be_nil

      browser = Client.new(BASE_URL)
      browser.cookies['rack.session'] = cookie.split('=', 2).last
      expect(secure_username(browser)).to eq name
    end

    it 'works for tomsmith' do
      res = api(:post, '/api/sessions', { username: 'tomsmith', password: 'SuperSecretPassword!' })
      expect(res.code).to eq '200'
      expect(secure_username).to eq 'tomsmith'
    end

    it 'answers 401 for a wrong password or an unknown user' do
      name = unique_name
      create(name)
      [[name, 'nope'], [unique_name, 'secret'], ['tomsmith', 'nope']].each do |username, password|
        res = api(:post, '/api/sessions', { username: username, password: password })
        expect(res.code).to eq '401'
        expect(json(res)['error']).to be_a String
      end
    end

    it 'answers 400 for a body without credentials' do
      expect(api(:post, '/api/sessions', 'nope').code).to eq '400'
      expect(api(:post, '/api/sessions', { username: 'x' }).code).to eq '400'
    end
  end

  # rake contract boots the app with two puma workers, so these requests are
  # spread over both processes.
  describe 'concurrency' do
    it 'creates the same username once when many requests race' do
      name = unique_name
      codes = Array.new(20) { Thread.new { create(name, 'secret', Client.new(BASE_URL)).code } }.map(&:value)
      expect(codes.sort).to eq ['201'] + ['409'] * 19
    end

    it 'creates different usernames at once, and all of them can log in' do
      names = Array.new(20) { unique_name }
      codes = names.map { |n| Thread.new { create(n, 'pw', Client.new(BASE_URL)).code } }.map(&:value)
      expect(codes).to all(eq '201')

      logged_in = names.map do |n|
        Thread.new do
          browser = Client.new(BASE_URL)
          login(n, 'pw', browser)
          secure_username(browser)
        end
      end.map(&:value)
      expect(logged_in).to eq names
    end
  end
end
