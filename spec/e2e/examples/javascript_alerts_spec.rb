require_relative '../spec_helper'

describe 'Examples' do
  it 'JavaScript Alerts: alert, confirm and prompt' do
    visit '/javascript_alerts'
    find(:xpath, "//button[text()='Click for JS Alert']").click
    @driver.switch_to.alert.accept
    expect(find(:id, 'result').text).to eq 'You successfully clicked an alert'

    find(:xpath, "//button[text()='Click for JS Confirm']").click
    @driver.switch_to.alert.dismiss
    expect(find(:id, 'result').text).to eq 'You clicked: Cancel'

    find(:xpath, "//button[text()='Click for JS Prompt']").click
    @driver.switch_to.alert.tap { |a| a.send_keys('Sauce') }.accept
    expect(find(:id, 'result').text).to eq 'You entered: Sauce'
  end
end
