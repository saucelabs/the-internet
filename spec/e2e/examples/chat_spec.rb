require 'securerandom'
require_relative '../spec_helper'

describe 'Examples' do
  # Two browsers, two users. A random room keeps parallel runs apart.
  it 'Chat: two users in one room see each other' do
    skip 'safaridriver runs one session at a time' if ENV['BROWSER'] == 'safari' && ENV['TARGET'] == 'local'
    room = "e2e-#{SecureRandom.hex(8)}"
    alice = @driver
    bob = start_browser('Chat: second user')

    join = lambda do |browser, name|
      browser.get "#{ENV['BASE_URL']}/chat?room=#{room}"
      Selenium::WebDriver::Wait.new(timeout: 10).until { browser.find_element(:id, 'status').text == 'Connected' }
      browser.find_element(:id, 'name').send_keys(name)
      browser.find_element(:id, 'join').click
      Selenium::WebDriver::Wait.new(timeout: 10).until { browser.find_element(:id, 'message').enabled? }
    end
    notices = ->(browser) { browser.find_elements(:css, '#messages .notice').map(&:text) }
    messages = lambda do |browser|
      browser.find_elements(:css, '#messages .message').map do |li|
        [li.find_element(:class, 'author').text, li.find_element(:class, 'text').text]
      end
    end

    join.call(alice, 'Alice')
    expect(find(:id, 'messages').attribute('role')).to eq 'log'
    join.call(bob, 'Bob')
    wait { notices.call(alice) == ['Alice joined', 'Bob joined'] }
    wait { notices.call(bob) == ['Bob joined'] }

    # Enter sends; the text shows as text, not HTML.
    find(:id, 'message').send_keys('Hi <b>Bob</b>', :enter)
    bob.find_element(:id, 'message').send_keys('Hi Alice')
    bob.find_element(:id, 'send').click
    expected = [['Alice', 'Hi <b>Bob</b>'], ['Bob', 'Hi Alice']]
    wait { messages.call(alice) == expected }
    wait { messages.call(bob) == expected }

    # Empty messages are ignored.
    find(:id, 'message').send_keys('   ', :enter)
    sleep 1
    expect(messages.call(bob).size).to eq 2

    bob.quit
    bob = nil
    wait { notices.call(alice).last == 'Bob left' }
  ensure
    bob&.quit
  end
end
