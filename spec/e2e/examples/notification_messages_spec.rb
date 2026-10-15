require_relative '../spec_helper'

describe 'Examples' do
  it 'Notification Messages shows a flash' do
    visit '/notification_message'
    expect(find(:id, 'flash').text).to match(/Action (successful|unsuccesful, please try again)/)
  end
end
