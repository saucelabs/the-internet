require_relative '../spec_helper'

describe 'Examples' do
  it 'Page chrome has a skip link for keyboard users',
     unsupported: { 'safari' => 'Safari does not Tab to links by default' } do
    visit '/checkboxes'
    skip_link = find(:css, 'a.skip-link')
    expect(skip_link.rect.y).to be < 0
    @driver.action.send_keys(:tab).perform
    expect(@driver.switch_to.active_element).to eq skip_link
    expect(skip_link.rect.y).to be >= 0
    skip_link.click
    expect(@driver.current_url).to end_with '#content'
  end

  it 'Page chrome links the title in the top bar to the home page' do
    visit '/checkboxes'
    home = find(:css, 'a.home-link')
    expect(home.text).to eq ''
    expect(home.accessible_name).to eq 'The Internet: home'
    home.click
    wait { @driver.current_url == "#{ENV['BASE_URL']}/" }
    expect(find(:css, 'h1.heading').text).to eq 'Welcome to the-internet'
  end
end
