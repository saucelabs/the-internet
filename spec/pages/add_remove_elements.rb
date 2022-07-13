require_relative 'page'

class AddRemoveElements < Page
  TITLE = { css: 'h3' }
  ADD_ELEMENT = { css: 'button' }
  DELETE = { css: '.added-manually' }

  def initialize(driver)
    super
    visit('/add_remove_elements/')
    raise 'Add/Remove elements page not ready' unless is_displayed?(ADD_ELEMENT)
  end

  def add_element
    click(ADD_ELEMENT)
  end

  def delete
    click(DELETE)
  end

  def add_element_button_present?
    wait_for(1) { is_displayed? ADD_ELEMENT }
    is_displayed? ADD_ELEMENT
  end

  def delete_button_present?
    wait_for(2) { is_displayed? DELETE }
    is_displayed? DELETE
  end

  def delete_button_not_present?
    wait_for(2) { not_displayed? DELETE }
    not_displayed? DELETE
  end
end
