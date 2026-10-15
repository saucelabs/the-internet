require_relative '../spec_helper'

describe 'Examples' do
  it 'Dropdown selects an option' do
    visit '/dropdown'
    select = Selenium::WebDriver::Support::Select.new(find(:id, 'dropdown'))
    select.select_by(:text, 'Option 2')
    expect(select.first_selected_option.text).to eq 'Option 2'
  end
end
