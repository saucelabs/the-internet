require_relative '../spec_helper'

describe 'Examples' do
  it 'Multiple Select Dropdown selects several options' do
    visit '/multiple_dropdown'
    select = Selenium::WebDriver::Support::Select.new(find(:id, 'multiple-dropdown'))
    expect(select).to be_multiple
    select.select_by(:text, 'Option 1')
    select.select_by(:text, 'Option 3')
    expect(select.selected_options.map(&:text)).to eq ['Option 1', 'Option 3']
    expect(@driver.find_elements(:css, '#multiple-dropdown option[selected]').map(&:text)).to eq ['Option 1', 'Option 3']
  end
end
