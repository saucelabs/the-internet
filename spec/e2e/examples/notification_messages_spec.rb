require_relative '../spec_helper'

describe 'Examples' do
  it 'Notification Messages shows a flash' do
    visit '/notification_message'
    expect(find(:id, 'flash').text).to match(/Action (successful|unsuccesful, please try again)/)
  end

  it 'Notification Messages closes the flash with its close link' do
    # In small windows the GitHub ribbon covers the close link.
    @driver.manage.window.resize_to(1280, 800)
    visit '/notification_message'
    find(:css, '#flash a.close').click
    wait { @driver.find_elements(:id, 'flash').none?(&:displayed?) }
  end
end
