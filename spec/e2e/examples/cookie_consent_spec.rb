require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/cookie_consent' }

  it 'Cookie Consent: accepting hides the banner for good' do
    expect(find(:id, 'cookie-banner')).to be_displayed
    find(:id, 'accept-all').click
    wait { find(:id, 'consent-status').text == 'Analytics cookies: allowed' }
    expect(@driver.find_elements(:id, 'cookie-banner')).to be_empty
    expect(@driver.manage.cookie_named('cookie_consent')[:value]).to eq 'all'
    visit '/cookie_consent'
    expect(@driver.find_elements(:id, 'cookie-banner')).to be_empty
  end

  it 'Cookie Consent: customizes, then forgets the choice' do
    find(:id, 'customize').click
    find(:id, 'save-settings').click
    wait { find(:id, 'consent-status').text == 'Analytics cookies: blocked' }
    find(:id, 'reset-consent').click
    expect(find(:id, 'cookie-banner')).to be_displayed
    expect(find(:id, 'consent-status').text).to eq 'Analytics cookies: not decided yet'
  end

  it 'Cookie Consent: a test can skip the banner by setting the cookie first' do
    @driver.manage.add_cookie(name: 'cookie_consent', value: 'necessary')
    visit '/cookie_consent'
    expect(@driver.find_elements(:id, 'cookie-banner')).to be_empty
  end
end
