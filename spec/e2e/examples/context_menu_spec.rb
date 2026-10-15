require_relative '../spec_helper'

describe 'Examples' do
  it 'Context Menu opens an alert on right click', unsupported: { 'safari' => 'safaridriver hangs when an action opens an alert' } do
    visit '/context_menu'
    @driver.action.context_click(find(:id, 'hot-spot')).perform
    alert = wait { @driver.switch_to.alert }
    expect(alert.text).to eq 'You selected a context menu'
    alert.accept
  end
end
