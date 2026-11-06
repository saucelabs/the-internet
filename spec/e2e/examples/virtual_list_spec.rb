require_relative '../spec_helper'

describe 'Examples' do
  it 'Virtualized List: a far away row only exists after scrolling to it' do
    visit '/virtual_list'
    rows = @driver.find_elements(:css, '#viewport .virtual-row')
    expect(rows.size).to be < 40
    expect(@driver.find_elements(:css, ".virtual-row[data-index='5000']")).to be_empty
    @driver.execute_script('arguments[0].scrollTop = 4999 * 30', find(:id, 'viewport'))
    row = wait { find(:css, ".virtual-row[data-index='5000']") }
    expect(row.text).to eq 'Item 5000'
    expect(@driver.find_elements(:css, ".virtual-row[data-index='1']")).to be_empty
  end

  it 'Virtualized List: scrolling with the wheel draws new rows' do
    visit '/virtual_list'
    viewport = find(:id, 'viewport')
    origin = Selenium::WebDriver::WheelActions::ScrollOrigin.element(viewport)
    @driver.action.scroll_from(origin, 0, 3000).perform
    wait { find(:id, 'rendered-range').text !~ /\ARows in the DOM: 1 to / }
    expect(@driver.find_elements(:css, ".virtual-row[data-index='100']")).not_to be_empty
  end
end
