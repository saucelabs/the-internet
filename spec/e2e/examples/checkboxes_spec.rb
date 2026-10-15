require_relative '../spec_helper'

describe 'Examples' do
  it 'Checkboxes toggle' do
    visit '/checkboxes'
    first, second = @driver.find_elements(:css, '#checkboxes input')
    expect([first.selected?, second.selected?]).to eq [false, true]
    first.click
    second.click
    expect([first.selected?, second.selected?]).to eq [true, false]
  end
end
