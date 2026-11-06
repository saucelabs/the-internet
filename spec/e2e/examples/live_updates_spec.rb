require_relative '../spec_helper'

describe 'Examples' do
  it 'Live Updates: shows each update as the server sends it' do
    visit '/live_updates?count=3&interval=500'
    find(:id, 'start').click
    wait(5) { @driver.find_elements(:css, '#updates .update').size == 1 }
    expect(find(:id, 'connection').text).to eq 'Connected, waiting for updates'
    wait(5) { find(:id, 'connection').text == 'Done: the server sent all updates' }
    expect(@driver.find_elements(:css, '#updates .update').map(&:text)).to eq ['Update 1 of 3', 'Update 2 of 3', 'Update 3 of 3']
  end
end
