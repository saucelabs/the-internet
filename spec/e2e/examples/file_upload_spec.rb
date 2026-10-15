require_relative '../spec_helper'
require 'tempfile'

describe 'Examples' do
  it 'File Upload uploads a file' do
    file = Tempfile.new(['e2e-upload', '.txt']).tap { |f| f.write('hello'); f.close }
    visit '/upload'
    @driver.file_detector = ->(args) { args.first.to_s if File.exist?(args.first.to_s) } if ENV['TARGET'] == 'saucelabs'
    find(:id, 'file-upload').send_keys(file.path)
    find(:id, 'file-submit').click
    expect(wait { find(:id, 'uploaded-files') }.text.strip).to eq File.basename(file.path)
  ensure
    file&.unlink
  end
end
