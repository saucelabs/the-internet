require_relative '../spec_helper'

describe 'Examples' do
  it 'Date & Time Pickers: picks a day in the calendar widget' do
    visit '/date_pickers?month=2026-03'
    find(:id, 'open-calendar').click
    expect(find(:id, 'calendar-month').text).to eq 'March 2026'
    find(:id, 'next-month').click
    expect(find(:id, 'calendar-month').text).to eq 'April 2026'
    find(:css, "#calendar-days button[data-date='2026-04-15']").click
    expect(find(:id, 'widget-date').attribute('value')).to eq '2026-04-15'
    expect(find(:id, 'calendar')).not_to be_displayed
  end

  it 'Date & Time Pickers: native inputs report values in a fixed format' do
    visit '/date_pickers'
    # The picker UI and typing order depend on the browser and locale, so set values the way a picker would.
    { 'date' => '2026-04-15', 'time' => '10:30' }.each do |id, value|
      @driver.execute_script(
        "arguments[0].value = arguments[1]; arguments[0].dispatchEvent(new Event('input', { bubbles: true }))",
        find(:id, id), value
      )
    end
    expect(find(:id, 'native-result').text).to eq 'date: 2026-04-15, time: 10:30'
    expect(find(:id, 'date').attribute('type')).to eq 'date'
  end
end
