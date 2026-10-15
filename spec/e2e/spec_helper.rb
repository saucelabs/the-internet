# Browser tests (Selenium 4). Run locally (headless) or on Sauce Labs:
#
#   bundle exec rake e2e                                   # boots the app, local headless Chrome, 4 processes
#   bundle exec parallel_rspec -n 4 spec/e2e               # against a running app; splits by file
#   BROWSER=firefox HEADLESS=false bundle exec rake e2e
#   TARGET=saucelabs BROWSER=safari bundle exec rspec spec/e2e   # needs SAUCE_USERNAME / SAUCE_ACCESS_KEY
#
# BASE_URL defaults to http://localhost:9292. On Sauce Labs an app on this machine
# needs a Sauce Connect tunnel (set SAUCE_TUNNEL_NAME) and a hostname other than
# localhost (Sauce browsers bypass the tunnel for localhost; see ci.yml).
#
# examples/ holds one file per example so parallel_rspec can spread them evenly.
require 'selenium-webdriver'

ENV['BASE_URL'] ||= 'http://localhost:9292'
ENV['TARGET']   ||= 'local'
ENV['BROWSER']  ||= 'chrome'

module Driver
  module_function

  # Chrome and Edge flag the example password as breached and open a dialog that eats keystrokes.
  def options
    options = Selenium::WebDriver::Options.send(ENV['BROWSER'])
    if %w[chrome edge].include?(ENV['BROWSER'])
      options.add_preference(:credentials_enable_service, false)
      options.add_preference(:profile, password_manager_enabled: false, password_manager_leak_detection: false)
    end
    options
  end

  def local
    options = self.options
    if ENV.fetch('HEADLESS', 'true') == 'true'
      case ENV['BROWSER']
      when 'chrome', 'edge' then options.add_argument('--headless=new')
      when 'firefox' then options.add_argument('-headless')
      end
    end
    Selenium::WebDriver.for(ENV['BROWSER'].to_sym, options: options)
  end

  def saucelabs(name)
    options = self.options
    options.browser_version = ENV.fetch('BROWSER_VERSION', 'latest')
    options.platform_name = ENV.fetch('PLATFORM_NAME') { ENV['BROWSER'] == 'safari' ? 'macOS 15' : 'Windows 11' }
    sauce = {
      username: ENV.fetch('SAUCE_USERNAME'),
      accessKey: ENV.fetch('SAUCE_ACCESS_KEY'),
      name: name,
      build: ENV.fetch('SAUCE_BUILD', "the-internet local #{Time.now.strftime('%F %R')}")
    }
    sauce[:tunnelName] = ENV['SAUCE_TUNNEL_NAME'] if ENV['SAUCE_TUNNEL_NAME']
    options.add_option('sauce:options', sauce)
    region = ENV.fetch('SAUCE_REGION', 'us-west-1')
    Selenium::WebDriver.for(:remote, url: "https://ondemand.#{region}.saucelabs.com/wd/hub", options: options)
  end
end

module E2EHelpers
  def visit(path)
    @driver.get ENV['BASE_URL'] + path
  end

  def find(*locator)
    @driver.find_element(*locator)
  end

  def wait(timeout = 10, &block)
    Selenium::WebDriver::Wait.new(timeout: timeout, ignore: Selenium::WebDriver::Error::NoSuchElementError).until(&block)
  end
end

RSpec.configure do |config|
  config.include E2EHelpers

  # Tag a scenario with `unsupported: { 'browser' => 'reason' }` to skip it there.
  config.before(:each) do |example|
    reason = example.metadata.dig(:unsupported, ENV['BROWSER'])
    skip(reason) if reason
    @driver =ENV['TARGET'] == 'saucelabs' ? Driver.saucelabs(example.metadata[:full_description]) : Driver.local
  end

  config.after(:each) do |example|
    if @driver && ENV['TARGET'] == 'saucelabs'
      @driver.execute_script("sauce:job-result=#{example.exception.nil?}")
      puts "Sauce Labs job: https://app.saucelabs.com/tests/#{@driver.session_id}" if example.exception
    end
  ensure
    @driver&.quit
  end
end
