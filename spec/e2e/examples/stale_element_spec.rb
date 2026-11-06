require_relative '../spec_helper'

describe 'Examples' do
  it 'Stale Element: an element from before the rebuild is stale' do
    visit '/stale_element'
    item = find(:css, '#items .item')
    expect(item.text).to eq 'Item 1'
    find(:id, 'rerender').click
    expect(find(:id, 'render-count').text).to eq 'Rebuilt 1 time'
    expect { item.text }.to raise_error(Selenium::WebDriver::Error::StaleElementReferenceError)
    expect(find(:css, '#items .item').text).to eq 'Item 1'
  end

  it 'Stale Element: the timer rebuilds the list on its own' do
    visit '/stale_element?interval=500'
    expect(find(:id, 'timer-status').text).to eq 'Timer: every 500 ms'
    item = find(:id, 'items')
    wait(5) do
      item.displayed?
      false
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      true
    end
  end
end
