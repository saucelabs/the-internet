require_relative '../spec_helper'

describe 'Examples' do
  it 'Autocomplete: picks a suggestion with the keyboard' do
    visit '/autocomplete'
    find(:id, 'autocomplete').send_keys('gr')
    wait { find(:id, 'suggestions').displayed? }
    expect(@driver.find_elements(:css, '#suggestions [role=option]').map(&:text)).to eq %w[Grape Grapefruit]
    find(:id, 'autocomplete').send_keys(:arrow_down, :arrow_down, :enter)
    expect(find(:id, 'selected').text).to eq 'You selected: Grapefruit'
    expect(find(:id, 'autocomplete').attribute('value')).to eq 'Grapefruit'
  end

  it 'Autocomplete: picks a suggestion with the mouse' do
    visit '/autocomplete?delay=0'
    find(:id, 'autocomplete').send_keys('man')
    option = wait { find(:css, '#suggestions [role=option]') }
    option.click
    expect(find(:id, 'selected').text).to eq 'You selected: Mango'
  end
end
