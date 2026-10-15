require_relative '../spec_helper'

describe 'Examples' do
  it 'Key Presses reports the key' do
    visit '/key_presses'
    find(:id, 'target').send_keys(:tab)
    expect(find(:id, 'result').text).to eq 'You entered: TAB'
  end
end
