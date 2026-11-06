require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/slow_api' }

  def set(id, value)
    find(:id, id).clear
    find(:id, id).send_keys(value)
  end

  it 'Slow & Failing API: waits for a slow answer' do
    set('delay', '1500')
    find(:id, 'call-api').click
    expect(find(:id, 'status-text').text).to eq 'Loading (attempt 1)...'
    wait(5) { find(:id, 'status-text').text == 'Data loaded on attempt 1' }
  end

  it 'Slow & Failing API: retries after errors until it works' do
    set('delay', '0')
    set('fail', '2')
    Selenium::WebDriver::Support::Select.new(find(:id, 'status')).select_by(:value, '429')
    find(:id, 'call-api').click
    wait(10) { find(:id, 'status-text').text == 'Data loaded on attempt 3' }
    expect(@driver.find_elements(:css, '#attempts li').map(&:text)).to eq [
      '429: Attempt 1 failed with 429', '429: Attempt 2 failed with 429', '200: Data loaded on attempt 3'
    ]
  end

  it 'Slow & Failing API: gives up without retries' do
    set('delay', '0')
    set('fail', '1')
    find(:id, 'retry').click
    find(:id, 'call-api').click
    wait(5) { find(:id, 'status-text').text == 'Gave up after 1 attempt (last status 500)' }
  end
end
