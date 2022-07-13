require_relative 'page'

class Checkboxes < Page
  CHECKBOXES_FORM = { id: 'checkboxes' }
  CHECKBOXES = { css: '[type="checkbox"]' }

  def initialize(driver)
    super
    visit('/checkboxes')
    raise 'Checkboxes page not ready' unless is_displayed?(CHECKBOXES_FORM)
  end

  def select_checkbox(number)
    all(CHECKBOXES)[number].click
  end

  def is_checked?(number)
    all(CHECKBOXES)[number].property('checked')
  end
end
