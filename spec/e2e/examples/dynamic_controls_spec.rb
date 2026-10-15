require_relative '../spec_helper'

describe 'Examples' do
  it 'Dynamic Controls removes the checkbox and enables the input' do
    visit '/dynamic_controls'
    find(:css, '#checkbox-example button').click
    expect(wait { find(:id, 'message') }.text).to eq "It's gone!"
    find(:css, '#input-example button').click
    wait { find(:css, '#input-example input').enabled? }
    expect(find(:id, 'message').text).to eq "It's enabled!"
  end
end
