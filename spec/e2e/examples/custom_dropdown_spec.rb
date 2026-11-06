require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/custom_dropdown' }

  it 'Custom Dropdown: selects an option with the mouse' do
    expect { Selenium::WebDriver::Support::Select.new(find(:id, 'fruit-combo')) }
      .to raise_error(ArgumentError, /unexpected tag name/)
    find(:id, 'fruit-combo').click
    expect(find(:id, 'fruit-combo').attribute('aria-expanded')).to eq 'true'
    find(:id, 'fruit-mango').click
    expect(find(:id, 'fruit-combo').text).to eq 'Mango'
    expect(find(:id, 'result').text).to eq 'Selected: mango'
  end

  it 'Custom Dropdown: skips the disabled option with the keyboard' do
    combo = find(:id, 'fruit-combo')
    combo.send_keys(:arrow_down)
    combo.send_keys(:arrow_down, :arrow_down, :enter)
    expect(find(:id, 'result').text).to eq 'Selected: mango'
    find(:id, 'fruit-combo').click
    find(:id, 'fruit-cherry').click
    expect(find(:id, 'result').text).to eq 'Selected: mango'
  end
end
