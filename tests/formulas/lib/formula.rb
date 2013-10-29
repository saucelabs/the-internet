# Encoding: utf-8

class Formula < ChemistryKit::Formula::Base

attr_reader :driver

  def initialize(driver)
    @driver = driver
  end

  def visit(destination_url)
    if destination_url.include? 'http'
      url = destination_url
    else
      url = ENV['BASE_URL'] + destination_url
    end
    driver.get url unless current_url == url
  end

  def find(locator)
    driver.find_element(locator)
  end

  def type(locator, text)
    find(locator).send_keys text
  end

  def click_on(locator)
    if locator.is_a? Hash
      find(locator).click
    else
      locator.click
    end
  end

  def submit(locator)
    find(locator).submit
  end

  def attribute_for(locator, value)
    find(locator).attribute(value)
  end

  def wait_for(seconds = 2)
    Selenium::WebDriver::Wait.new(timeout: seconds).until { yield }
  end

  def rescue_exceptions
    yield
    rescue Selenium::WebDriver::Error::NoSuchElementError
      false
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      false
    rescue Selenium::WebDriver::Error::TimeOutError
      false
    rescue Selenium::WebDriver::Error::NoAlertPresentError
      false
    rescue Selenium::WebDriver::Error::UnknownError
      false
  end

  def displayed?(locator)
    rescue_exceptions { find(locator).displayed? }
  end

  def not_displayed?(locator)
    rescue_exceptions { find(locator).displayed? } == false
  end

  def download_file_from(url)
    require 'rest-client'
    RestClient.head url
  end

end
