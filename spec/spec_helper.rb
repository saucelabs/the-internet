require 'selenium-webdriver'
require 'eyes_selenium'
require_relative 'lib/batch_info'

RSpec.configure do |config|

  config.before(:all) do
    Thread.current[:batch] = Applitools::Base::BatchInfo.new('Walkthrough')
    Thread.current[:batch].set_id(ENV['batch_id'])
  end

  config.before(:each) do |example|
    @browser                  = Selenium::WebDriver.for :firefox
    @eyes                     = Applitools::Eyes.new
    @eyes.api_key             = ENV['APPLITOOLS_API_KEY']
    @eyes.batch               = Thread.current[:batch]
    @driver                   = @eyes.open(
      app_name:       'the-internet',
      test_name:      example.metadata[:full_description],
      viewport_size:  { width:  ENV['viewport_width'].to_i,
                        height: ENV['viewport_height'].to_i },
      driver:         @browser)
  end

  config.after(:each) do
    begin
      @eyes.close
    ensure
      @eyes.abort_if_not_closed
      @browser.quit
    end
  end

end
