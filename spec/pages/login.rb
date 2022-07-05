require_relative 'page'

class Login < Page

  LOGIN_FORM = { id: 'login' }
  USERNAME_INPUT = { id: 'username' }
  PASSWORD_INPUT = { id: 'password' }
  SUBMIT_BUTTON = { css: 'button' }
  SUCCESS_MESSAGE = { css: '.flash.success' }
  FAILURE_MESSAGE = { css: '.flash.error' }

  def initialize(driver)
    super
    visit ('/login')
    raise 'Login page not ready' unless is_displayed?(LOGIN_FORM)
  end

  def with(username, password)
    type username, USERNAME_INPUT
    type password, PASSWORD_INPUT
    click SUBMIT_BUTTON
  end

  def success_message_present?
    wait_for(1) { is_displayed? SUCCESS_MESSAGE }
    is_displayed? SUCCESS_MESSAGE
  end

  def failure_message_present?
    wait_for(1) { is_displayed? FAILURE_MESSAGE }
    is_displayed? FAILURE_MESSAGE
  end

end
