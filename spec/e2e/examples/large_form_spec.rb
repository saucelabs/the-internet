require_relative '../spec_helper'

describe 'Examples' do
  it 'Large Form submits fields with and without ids' do
    visit '/large_form'
    find(:id, 'first-name').send_keys('Ana')
    find(:name, 'email').send_keys('ana@example.com')
    Selenium::WebDriver::Support::Select.new(find(:id, 'country')).select_by(:value, 'ar')
    find(:css, 'input[name=contact][value=phone]').click
    find(:css, 'input.interest[value=automation]').click
    find(:id, 'terms').click
    find(:id, 'submit').click
    rows = wait { @driver.find_elements(:css, '#submitted-data tbody tr').then { |trs| trs unless trs.empty? } }.to_h { |tr| tr.find_elements(:tag_name, 'td').map { |td| td.text.strip } }
    expect(rows).to include('first_name' => 'Ana', 'email' => 'ana@example.com', 'country' => 'ar',
                            'contact' => 'phone', 'interests' => 'automation', 'terms' => 'accepted')
  end
end
