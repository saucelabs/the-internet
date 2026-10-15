require_relative '../spec_helper'

describe 'Examples' do
  it 'Radio Buttons select one option per group' do
    visit '/radio_buttons'
    expect(find(:id, 'blue')).to be_selected
    find(:id, 'red').click
    find(:css, 'input[name=sport][value=tennis]').click
    expect(find(:id, 'blue')).not_to be_selected
    expect(find(:css, 'input[value=hockey]')).not_to be_enabled
    expect(find(:id, 'result').text).to eq 'Color: red, Sport: tennis'
  end
end
