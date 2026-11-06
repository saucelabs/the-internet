require_relative '../spec_helper'

describe 'Examples' do
  it 'Home page filters the examples' do
    visit '/'
    items = @driver.find_elements(:css, '#content ul li')
    expect(items.size).to be > 40
    find(:id, 'example-filter').send_keys('checkbox')
    wait { items.count(&:displayed?) == 1 }
    expect(items.find(&:displayed?).find_element(:tag_name, 'a').text).to eq 'Checkboxes'
    find(:id, 'example-filter').send_keys('zzz')
    wait { find(:id, 'example-filter-empty').displayed? }
    expect(items.none?(&:displayed?)).to be true
  end

  it 'Home page shows a description under each example' do
    visit '/'
    item = find(:css, "#content ul li a[href='/checkboxes']").find_element(:xpath, '..')
    expect(item.attribute('data-description')).to eq 'Check and uncheck boxes'
    expect(item.text).to eq 'Checkboxes'
  end
end
