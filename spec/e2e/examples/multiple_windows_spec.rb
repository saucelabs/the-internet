require_relative '../spec_helper'

describe 'Examples' do
  it 'Multiple Windows opens and switches to a new window' do
    visit '/windows'
    original = @driver.window_handle
    find(:link_text, 'Click Here').click
    wait { @driver.window_handles.size == 2 }
    @driver.switch_to.window((@driver.window_handles - [original]).first)
    wait { @driver.title == 'New Window' }
  end
end
