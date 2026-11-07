require_relative '../spec_helper'

describe 'Examples' do
  it 'WebSocket: sends a message and shows the echo' do
    visit '/websocket'
    find(:id, 'connect').click
    wait(5) { find(:id, 'connection').text == 'Connected' }
    wait(5) { @driver.find_elements(:css, '#messages .received').size == 1 }
    find(:id, 'message').send_keys('hello', :enter)
    wait(5) { @driver.find_elements(:css, '#messages .received').size == 2 }
    expect(@driver.find_elements(:css, '#messages .message').map(&:text)).to eq [
      'Connected. Send a message and the server sends it back.', 'hello', 'Echo: hello'
    ]
    find(:id, 'disconnect').click
    wait(5) { find(:id, 'connection').text == 'Disconnected (code 1000: Closed by the page)' }
    expect(find(:id, 'send')).not_to be_enabled
  end
end
