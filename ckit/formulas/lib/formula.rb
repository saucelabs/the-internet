# Encoding: utf-8

class Formula < ChemistryKit::Formula::Base

  attr_reader :driver

  def initialize(driver)
    @driver = driver
  end

  def title
    driver.title
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

  def find_all_of(locator)
    driver.find_elements(locator)
  end

  def hover_over(locator)
    driver.mouse.move_to(find(locator))
  end

  def click_on(locator)
    if locator.is_a? Hash
      find(locator).click
    else
      locator.click
    end
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

  def text_of(locator)
    if locator.is_a? Hash
      find(locator).text
    else
      locator.text
    end
  end

  def link_of(locator)
    find(locator).attribute('href')
  end

  def type(locator, text)
    find(locator).send_keys text
  end

  def press(key)
    driver.action.send_keys(key).perform
  end

  def double_click_on(locator)
    driver.action.double_click(locator).perform
  end

  def clear(locator)
    find(locator).clear
  end

  def submit(locator)
    find(locator).submit
  end

  def select(locator, selection)
    drop_down_list = find(locator)
    options = drop_down_list.find_elements(tag_name: 'option')
    options.each { |option| option.click if option == selection }
  end

  def accept_alert
    alert = driver.switch_to.alert
    alert.accept
  end

  def dismiss_alert
    alert = driver.switch_to.alert
    alert.dismiss
  end

  def get_window_handle
    driver.window_handle
  end

  alias_method :current_window, :get_window_handle

  def get_window_handles
    driver.window_handles
  end

  def number_of_windows
    get_window_handles.count
  end

  def wait_for_multiple_windows
    try(attempts: 5, sleep: 1) { number_of_windows > 1 }
  end

  def get_new_window_handle_from(main_window)
    all_windows = get_window_handles
    all_windows.each do |window|
      return window if main_window != window
    end
  end

  def switch_to_new_window_from(main_window)
    wait_for_multiple_windows
    all_windows = get_window_handles
    all_windows.each do |window|
      switch_to_window window if main_window != window
    end
  end

  def switch_to_window(window)
    driver.switch_to.window window
  end

  def current_url
    driver.current_url
  end

  def wait(seconds = 2)
    Selenium::WebDriver::Wait.new(timeout: seconds).until { yield }
  end

  alias_method :wait_for, :wait
  alias_method :wait_until, :wait

  def close_dialogs
    Formulas::Dialogs.new(driver).close
  end

  def refresh
    driver.navigate.refresh
  end

  def execute_script(script)
    driver.execute_script script
  end

  def download_file_from_url(url)
    require 'rest-client'
    RestClient.get url
  end

  def raise_unknown_option_error(selection)
    raise ArgumentError, "Unknown option #{selection} provided!"
  end

  def try(args = {})
    count = 0
    object_of_interest = false
    until object_of_interest || count == args[:attempts]
      object_of_interest = rescue_exceptions { yield }
      sleep args[:sleep]
      count += 1
    end
    object_of_interest
  end

end # Formula
