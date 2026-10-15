require_relative '../spec_helper'

describe 'Examples' do
  it 'Infinite Scroll loads more content' do
    visit '/infinite_scroll'
    # The first chunk loads on its own; wait for it before scrolling.
    wait { @driver.find_elements(:css, '.jscroll-added').size.positive? }
    initial = @driver.find_elements(:css, '.jscroll-added').size
    wait do
      @driver.execute_script('window.scrollTo(0, document.body.scrollHeight)')
      @driver.find_elements(:css, '.jscroll-added').size > initial
    end
  end
end
