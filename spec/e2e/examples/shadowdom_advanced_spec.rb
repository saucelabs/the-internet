require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/shadowdom_advanced' }

  it 'Advanced Shadow DOM: clicks a button two shadow roots deep' do
    inner = find(:id, 'outer-card').shadow_root.find_element(:css, 'inner-card')
    inner.shadow_root.find_element(:css, '#inner-button').click
    expect(find(:id, 'nested-result').text).to eq 'You clicked the button in the inner shadow root'
  end

  it 'Advanced Shadow DOM: a closed shadow root is hidden from page scripts but not from WebDriver',
     unsupported: { 'safari' => 'safaridriver does not return closed shadow roots' } do
    host = find(:id, 'closed-card')
    expect(@driver.execute_script('return arguments[0].shadowRoot', host)).to be_nil
    expect(host.shadow_root.find_element(:css, '#closed-text').text).to eq 'This text is in a closed shadow root'
  end

  it 'Advanced Shadow DOM: slotted content stays in the light DOM' do
    expect(find(:css, '#slot-card [slot=title]').text).to eq 'Title from the light DOM'
    slot = find(:id, 'slot-card').shadow_root.find_element(:css, 'slot[name=footer]')
    expect(slot.text).to eq 'Default footer (nothing is slotted here)'
  end

  it 'Advanced Shadow DOM: a custom element submits its value with the form' do
    find(:id, 'name').send_keys('Ana')
    find(:css, '#rating-form button[type=submit]').click
    expect(find(:id, 'form-result').text).to eq 'Error: Pick a rating'
    find(:id, 'rating').shadow_root.find_element(:css, '#star-3').click
    find(:css, '#rating-form button[type=submit]').click
    expect(find(:id, 'form-result').text).to eq 'Submitted name: Ana, rating: 3'
  end
end
