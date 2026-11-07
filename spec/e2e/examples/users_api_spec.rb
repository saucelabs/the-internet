require_relative '../spec_helper'
require 'json'
require 'net/http'
require 'securerandom'

describe 'Examples' do
  def api(method, path, body = nil)
    uri = URI(ENV['BASE_URL'] + path)
    req = Net::HTTP.const_get(method.capitalize).new(uri, 'Content-Type' => 'application/json')
    req.body = JSON.generate(body) if body
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(req) }
  end

  it 'Users API: creates a user, logs in with it through the form, and deletes it' do
    username = "user-#{SecureRandom.hex(6)}"
    expect(api(:post, '/api/users', username: username, password: 'secret').code).to eq '201'
    begin
      visit '/login'
      find(:id, 'username').send_keys(username)
      find(:id, 'password').send_keys('secret')
      # Safari can click before the typed text is in the fields.
      wait { find(:id, 'username').property('value') == username && find(:id, 'password').property('value') == 'secret' }
      find(:css, 'button[type="submit"]').click
      wait { @driver.current_url.end_with?('/secure') }
      expect(find(:css, 'span#username').text).to eq username
      expect(find(:css, '.flash.success').text).to include 'You logged into a secure area!'
    ensure
      expect(api(:delete, "/api/users/#{username}").code).to eq '204'
    end
  end

  it 'Users API: opens /secure with the cookie from /api/sessions' do
    username = "user-#{SecureRandom.hex(6)}"
    api(:post, '/api/users', username: username, password: 'secret')
    res = api(:post, '/api/sessions', username: username, password: 'secret')
    name, value = res['set-cookie'].split(';').first.split('=', 2)
    visit '/login'
    # /login already set a session cookie; Safari keeps both unless the old one is removed.
    @driver.manage.delete_all_cookies
    @driver.manage.add_cookie(name: name, value: value, path: '/')
    visit '/secure'
    expect(find(:css, 'span#username').text).to eq username
  ensure
    api(:delete, "/api/users/#{username}")
  end
end
