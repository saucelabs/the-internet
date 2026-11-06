require_relative '../spec_helper'

describe 'Examples' do
  it 'Accessibility Issues: the issues are there on purpose' do
    visit '/accessibility_issues'
    expect(@driver.find_elements(:css, '#known-issues tbody tr').map { |r| r.attribute('data-rule') })
      .to eq %w[image-alt label select-name button-name link-name color-contrast aria-roles heading-order]
    expect(find(:id, 'profile-image').dom_attribute('alt')).to be_nil
    expect(find(:id, 'icon-button').dom_attribute('aria-label')).to be_nil
    expect(find(:id, 'bad-role').attribute('role')).to eq 'buton'
  end

  it 'Accessibility Issues: the fixed page has names and labels' do
    visit '/accessibility_issues?fixed=true'
    expect(find(:id, 'profile-image').attribute('alt')).to eq 'Profile photo'
    expect(find(:id, 'search-input').accessible_name).to eq 'Search'
    expect(find(:id, 'icon-button').accessible_name).to eq 'Settings'
    expect(find(:id, 'bad-role').aria_role).to eq 'button'
  end
end
