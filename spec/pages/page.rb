require 'selenium-webdriver'

class Page
  def initialize(driver)
    @driver = driver
  end

  def visit(url_path)
    @driver.navigate.to(ENV['base_url'] + url_path)
  end

  def find(locator)
    @driver.find_element locator
  end

  def all(locator)
    @driver.find_elements(locator)
  end

  def type(text, locator)
    find(locator).send_keys text
  end

  def click(locator)
    find(locator).click
  end

  def is_displayed?(locator)
    find(locator).displayed?
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

  def not_displayed?(locator)
    find(locator).displayed?
  rescue Selenium::WebDriver::Error::NoSuchElementError
    true
  end

  def wait_for(seconds = 15, &block)
    Selenium::WebDriver::Wait.new(timeout: seconds).until(&block)
  end
end
