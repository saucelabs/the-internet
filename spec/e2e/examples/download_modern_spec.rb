require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/download_modern' }

  it 'Modern File Download: saves files made in the browser' do
    find(:id, 'blob-download').click
    expect(find(:id, 'download-status').text).to eq 'Saved report.csv (28 bytes, text/csv)'
    find(:id, 'fetch-download').click
    wait { find(:id, 'download-status').text.start_with?('Saved report.json') }
    expect(find(:id, 'download-status').text).to eq 'Saved report.json (28 bytes, application/json)'
    expect(find(:id, 'data-url-download').attribute('download')).to eq 'hello.txt'
  end

  it 'Modern File Download: an inline file opens in the browser' do
    find(:link_text, 'inline.txt').click
    wait { @driver.current_url.end_with?('/download_modern/file/inline') }
    expect(find(:tag_name, 'body').text).to eq 'This file opens in the browser instead of downloading.'
  end
end
