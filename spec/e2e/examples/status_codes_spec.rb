require_relative '../spec_helper'

describe 'Examples' do
  it 'Status Codes link to pages that report the code' do
    visit '/status_codes'
    find(:link_text, '404').click
    expect(find(:css, '.example p').text).to include 'This page returned a 404 status code.'
  end
end
