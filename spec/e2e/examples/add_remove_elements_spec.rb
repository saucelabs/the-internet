require_relative '../spec_helper'

describe 'Examples' do
  it 'Add/Remove Elements adds and removes buttons' do
    visit '/add_remove_elements/'
    2.times { find(:css, '.example > button').click }
    expect(@driver.find_elements(:css, '#elements .added-manually').size).to eq 2
    find(:css, '#elements .added-manually').click
    expect(@driver.find_elements(:css, '#elements .added-manually').size).to eq 1
  end
end
