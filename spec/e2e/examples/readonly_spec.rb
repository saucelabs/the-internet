require_relative '../spec_helper'

describe 'Examples' do
  it 'Read-only Inputs ignore typing once read-only' do
    visit '/readonly'
    field = find(:id, 'textfield')
    field.send_keys('!')
    expect(field.property('value')).to eq 'I am editable!'
    find(:id, 'checkbox').click
    expect(field.attribute('readonly')).to be_truthy
    field.send_keys('!')
    expect(field.property('value')).to eq 'You cannot change me'
    expect(find(:id, 'disabled')).not_to be_enabled
  end
end
