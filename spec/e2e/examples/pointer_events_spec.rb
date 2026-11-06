require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/pointer_events' }

  it 'Pointer Events: drags an item to the end of the sortable list' do
    first = find(:css, "#sortable li[data-id='1']")
    last = find(:css, "#sortable li[data-id='4']")
    @driver.action.click_and_hold(first).move_to(last, 0, 15).release.perform
    expect(find(:id, 'order').text).to eq 'Order: Second, Third, Fourth, First'
  end

  it 'Pointer Events: swipes left' do
    area = find(:id, 'swipe-area')
    @driver.action.move_to(area, 100, 0).click_and_hold.move_by(-200, 0).release.perform
    expect(find(:id, 'swipe-result').text).to eq 'Swiped left (mouse)'
  end

  it 'Pointer Events: swipes right with a finger', unsupported: { 'safari' => 'safaridriver has no touch input' } do
    area = find(:id, 'swipe-area')
    finger = Selenium::WebDriver::Interactions.pointer(:touch, name: 'finger')
    @driver.action(devices: [finger])
           .move_to(area, -100, 0, device: 'finger')
           .pointer_down(:left, device: 'finger')
           .move_by(200, 0, duration: 0.2, device: 'finger')
           .pointer_up(:left, device: 'finger')
           .perform
    expect(find(:id, 'swipe-result').text).to eq 'Swiped right (touch)'
  end

  it 'Pointer Events: tells a long press from a short one' do
    button = find(:id, 'long-press')
    button.click
    expect(find(:id, 'press-result').text).to eq 'Short press (hold for 800 ms)'
    @driver.action.click_and_hold(button).pause(duration: 1.2).release.perform
    expect(find(:id, 'press-result').text).to eq 'Long press'
  end
end
