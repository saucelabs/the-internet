require 'rspec'
require 'selenium-webdriver'
require 'webdrivers/chromedriver'

RSpec.configure do |config|
  config.before(:each) do |example|
    ENV['base_url'] ||= 'http://localhost:9292'
    options = Selenium::WebDriver::Chrome::Options.new(options: { w3c: true })
    options.add_argument('--headless') if ENV['CI'] == 'true'
    @driver = Selenium::WebDriver.for(:chrome, options: options)
  end

  config.after(:each) do |example|
    @driver.close
  end
end
