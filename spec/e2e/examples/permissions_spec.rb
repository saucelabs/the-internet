require_relative '../spec_helper'

describe 'Examples' do
  it 'Browser Permissions: shows a state for each permission' do
    visit '/permissions'
    cells = @driver.find_elements(:css, '#permission-states tbody td[id^=state-]')
    wait { cells.none? { |c| c.text == 'checking' } }
    cells.each { |cell| expect(%w[granted denied prompt unsupported]).to include(cell.text) }
  end

  it 'Browser Permissions: turns on a fake camera', fake_media: true,
     unsupported: { 'safari' => 'safaridriver has no fake camera' } do
    visit '/permissions'
    # The camera API only exists on https pages and localhost (CI uses http://the-internet.test).
    skip 'needs https or localhost' unless @driver.execute_script('return window.isSecureContext')
    find(:id, 'start-camera').click
    wait { find(:id, 'camera-result').text.start_with?('Camera on: ') }
    wait { @driver.execute_script("return document.getElementById('camera-video').videoWidth") > 0 }
    find(:id, 'stop-camera').click
    expect(find(:id, 'camera-result').text).to eq 'Camera off'
  end
end
