require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/dialog' }

  it 'Native Dialog: confirms a modal dialog' do
    find(:id, 'open-modal').click
    expect(find(:id, 'modal-dialog')).to be_displayed
    find(:id, 'modal-name').send_keys('Ana')
    find(:id, 'modal-confirm').click
    expect(find(:id, 'modal-dialog')).not_to be_displayed
    expect(find(:id, 'result').text).to eq 'Modal dialog closed with: confirm (name: Ana)'
  end

  it 'Native Dialog: a modal dialog blocks the page and closes with Escape' do
    find(:id, 'open-modal').click
    # Chrome reports the click as intercepted, Firefox as not interactable.
    blocked = [Selenium::WebDriver::Error::ElementClickInterceptedError, Selenium::WebDriver::Error::ElementNotInteractableError]
    expect { find(:id, 'page-input').click }.to raise_error { |e| expect(blocked).to include(e.class) }
    @driver.action.send_keys(:escape).perform
    wait { !find(:id, 'modal-dialog').displayed? }
    expect(find(:id, 'result').text).to eq 'Modal dialog closed with Escape'
  end

  it 'Native Dialog: a non-modal dialog leaves the page usable' do
    find(:id, 'open-non-modal').click
    expect(find(:id, 'non-modal-dialog')).to be_displayed
    find(:id, 'page-input').send_keys('still works')
    expect(find(:id, 'page-input').attribute('value')).to eq 'still works'
    find(:id, 'non-modal-close').click
    expect(find(:id, 'result').text).to eq 'Non-modal dialog closed'
  end
end
