require_relative 'page'

class DynamicLoading < Page

  START_BUTTON = { css: '#start button' }
  FINISH_TEXT = { id: 'finish' }

  def example(example_number)
    visit ("/dynamic_loading/#{example_number}")
  end

  def start
    click(START_BUTTON)
  end

  def finish_text_present?
    wait_for(6) { is_displayed?(FINISH_TEXT) }
  end

end
