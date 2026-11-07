require_relative '../spec_helper'

describe 'Examples' do
  it 'Notification Messages shows a flash' do
    visit '/notification_message'
    expect(find(:id, 'flash').text).to match(/Action (successful|unsuccesful, please try again)/)
  end

  it 'Notification Messages closes the flash with its close link' do
    visit '/notification_message'
    find(:css, '#flash a.close').click
    # The flash fades out and is then removed, so it can go stale while we look at it.
    wait do
      @driver.find_elements(:id, 'flash').none?(&:displayed?)
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      false
    end
  end
end
