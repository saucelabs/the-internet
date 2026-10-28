require_relative '../spec_helper'
require 'tempfile'
require 'tmpdir'
require 'securerandom'
require 'fileutils'

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

  it 'File Upload cleans file names and File Download lists them as text' do
    dir = Dir.mktmpdir
    hex = SecureRandom.hex(4)
    path = File.join(dir, "e2e <b>#{hex}.txt")
    File.write(path, 'hello')
    visit '/upload'
    @driver.file_detector = ->(args) { args.first.to_s if File.exist?(args.first.to_s) } if ENV['TARGET'] == 'saucelabs'
    find(:id, 'file-upload').send_keys(path)
    find(:id, 'file-submit').click
    expect(wait { find(:id, 'uploaded-files') }.text.strip).to eq File.basename(path)
    visit '/download'
    expect(wait { find(:link_text, "e2e__b_#{hex}.txt") }).to be_displayed
    expect(@driver.find_elements(:css, '#content b')).to be_empty
  ensure
    FileUtils.rm_rf(dir) if dir
  end
end
