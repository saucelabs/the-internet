require 'selenium-webdriver'
require 'sauce_whisk'

RSpec.configure do |config|

  config.before(:each) do |example|
    ENV['host']             ||= 'saucelabs'
    ENV['base_url']         ||= 'http://the-internet.herokuapp.com'
    ENV['operating_system'] ||= 'Windows 10'
    ENV['browser']          ||= 'firefox'
    ENV['browser_version']  ||= '50.0'

    case ENV['host']
    when 'localhost'
      @driver = Selenium::WebDriver.for :chrome
    when 'saucelabs'
      caps = Selenium::WebDriver::Remote::Capabilities.send(ENV['browser'])
      caps[:platform]  = ENV['operating_system']
      caps[:version]   = ENV['browser_version']
      caps[:name]      = example.metadata[:full_description]
      @driver = Selenium::WebDriver.for(
        :remote,
        url: "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub",
        desired_capabilities: caps)
    end
  end

  config.after(:each) do |example|
    begin
      if ENV['host'] == 'saucelabs'
        if example.exception.nil?
          SauceWhisk::Jobs.pass_job @driver.session_id
        else
          SauceWhisk::Jobs.fail_job @driver.session_id
          raise "Watch a video of the test at https://saucelabs.com/tests/#{@driver.session_id}"
        end
      end
    ensure
      @driver.quit
    end
  end

end
