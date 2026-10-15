require_relative '../spec_helper'

describe 'Examples' do
  it 'Read-only Inputs ignore typing once read-only' do
    visit '/readonly'
    field = find(:id, 'textfield')
    field.clear
    field.send_keys('typed')
    expect(field.property('value')).to eq 'typed'

    find(:id, 'checkbox').click
    expect(field.attribute('readonly')).to be_truthy
    begin
      field.send_keys('more')
    rescue Selenium::WebDriver::Error::WebDriverError
      # Some drivers refuse to type into a read-only field; either way the value must not change.
    end
    expect(field.property('value')).to eq 'You cannot change me'
    expect(find(:id, 'disabled')).not_to be_enabled
  end
end
