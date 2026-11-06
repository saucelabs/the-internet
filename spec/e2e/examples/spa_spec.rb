require_relative '../spec_helper'

describe 'Examples' do
  it 'SPA Routing: changes the URL without reloading, and Back works' do
    visit '/spa'
    expect(find(:id, 'view-title').text).to eq 'Home'
    @driver.execute_script('window.loadMarker = true')
    find(:link_text, 'About').click
    expect(find(:id, 'view-title').text).to eq 'About'
    expect(@driver.current_url).to end_with '/spa/about'
    find(:link_text, 'Contact').click
    expect(@driver.current_url).to end_with '/spa/contact'
    @driver.navigate.back
    wait { find(:id, 'view-title').text == 'About' }
    expect(@driver.current_url).to end_with '/spa/about'
    expect(@driver.execute_script('return window.loadMarker')).to be true
  end

  it 'SPA Routing: opens a view from its URL' do
    visit '/spa/contact'
    expect(find(:id, 'view-title').text).to eq 'Contact'
    expect(find(:css, '#spa-nav a[aria-current=page]').text).to eq 'Contact'
  end
end
