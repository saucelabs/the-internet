require_relative 'spec_helper'

describe 'Walkthrough' do

  it 'Homepage' do
    @driver.get ENV['base_url']
    @eyes.check_window('/')
  end

end
