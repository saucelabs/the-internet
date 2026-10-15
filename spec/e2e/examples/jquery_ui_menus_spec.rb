require_relative '../spec_helper'

describe 'Examples' do
  it 'JQuery UI Menus open sub-menus on hover' do
    visit '/jqueryui/menu'
    enabled = find(:id, 'ui-id-3')
    @driver.action.move_to(enabled).perform
    # jQuery UI opens sub-menus after a short delay.
    wait { find(:id, 'ui-id-4').displayed? }
  end
end
