require_relative '../spec_helper'

describe 'Examples' do
  it 'Broken Images has two images that failed to load' do
    visit '/broken_images'
    broken = @driver.find_elements(:css, '.example img').count do |img|
      @driver.execute_script('return arguments[0].naturalWidth', img).zero?
    end
    expect(broken).to eq 2
  end
end
