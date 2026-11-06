require_relative '../spec_helper'

describe 'Examples' do
  def layout
    @driver.execute_script("return getComputedStyle(document.getElementById('layout-name'), '::after').content").delete('"')
  end

  it 'Responsive Layout: shows the full menu on a wide window' do
    @driver.manage.window.resize_to(1280, 800)
    visit '/responsive'
    expect(layout).to eq 'desktop'
    expect(find(:id, 'menu-toggle')).not_to be_displayed
    find(:link_text, 'Pricing').click
    expect(find(:id, 'nav-result').text).to eq 'You clicked Pricing'
  end

  it 'Responsive Layout: uses a menu button on a narrow window' do
    @driver.manage.window.resize_to(500, 800)
    visit '/responsive'
    wait { layout == 'mobile' }
    # A hidden link has no visible text, so find it by CSS, not by link text.
    expect(find(:css, "#site-nav a[href='#pricing']")).not_to be_displayed
    find(:id, 'menu-toggle').click
    expect(find(:id, 'menu-toggle').attribute('aria-expanded')).to eq 'true'
    find(:css, "#site-nav a[href='#pricing']").click
    expect(find(:id, 'nav-result').text).to eq 'You clicked Pricing'
    expect(find(:css, "#site-nav a[href='#pricing']")).not_to be_displayed
    expect(find(:id, 'card-2').rect.x).to eq find(:id, 'card-1').rect.x
  end
end
