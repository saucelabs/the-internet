require_relative '../spec_helper'

describe 'Examples' do
  it 'Sortable Data Tables sort by last name' do
    visit '/tables'
    find(:css, '#table2 thead .last-name').click
    names = -> { @driver.find_elements(:css, '#table2 tbody .last-name').map(&:text) }
    wait { names.call == names.call.sort }
  end
end
