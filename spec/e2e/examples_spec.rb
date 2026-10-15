require_relative 'spec_helper'
require 'tempfile'

# One short scenario per example, mirroring how people automate the site.
describe 'Examples' do
  it 'A/B Testing shows a heading' do
    visit '/abtest'
    expect(find(:css, '.example h3').text).to match(/A\/B Test|No A\/B Test/)
  end

  it 'Add/Remove Elements adds and removes buttons' do
    visit '/add_remove_elements/'
    2.times { find(:css, '.example > button').click }
    expect(@driver.find_elements(:css, '#elements .added-manually').size).to eq 2
    find(:css, '#elements .added-manually').click
    expect(@driver.find_elements(:css, '#elements .added-manually').size).to eq 1
  end

  it 'Basic Auth accepts credentials in the URL', unsupported: { 'safari' => 'Safari ignores credentials in URLs' } do
    uri = URI(ENV['BASE_URL'])
    @driver.get "#{uri.scheme}://admin:admin@#{uri.host}:#{uri.port}/basic_auth"
    expect(find(:css, '.example p').text).to include 'Congratulations!'
  end

  it 'Broken Images has two images that failed to load' do
    visit '/broken_images'
    broken = @driver.find_elements(:css, '.example img').count do |img|
      @driver.execute_script('return arguments[0].naturalWidth', img).zero?
    end
    expect(broken).to eq 2
  end

  it 'Checkboxes toggle' do
    visit '/checkboxes'
    first, second = @driver.find_elements(:css, '#checkboxes input')
    expect([first.selected?, second.selected?]).to eq [false, true]
    first.click
    second.click
    expect([first.selected?, second.selected?]).to eq [true, false]
  end

  it 'Context Menu opens an alert on right click', unsupported: { 'safari' => 'safaridriver hangs when an action opens an alert' } do
    visit '/context_menu'
    @driver.action.context_click(find(:id, 'hot-spot')).perform
    alert = wait { @driver.switch_to.alert }
    expect(alert.text).to eq 'You selected a context menu'
    alert.accept
  end

  it 'Dropdown selects an option' do
    visit '/dropdown'
    select = Selenium::WebDriver::Support::Select.new(find(:id, 'dropdown'))
    select.select_by(:text, 'Option 2')
    expect(select.first_selected_option.text).to eq 'Option 2'
  end

  it 'Dynamic Controls removes the checkbox and enables the input' do
    visit '/dynamic_controls'
    find(:css, '#checkbox-example button').click
    expect(wait { find(:id, 'message') }.text).to eq "It's gone!"
    find(:css, '#input-example button').click
    wait { find(:css, '#input-example input').enabled? }
    expect(find(:id, 'message').text).to eq "It's enabled!"
  end

  it 'Entry Ad shows a modal that can be closed' do
    visit '/entry_ad'
    modal = find(:id, 'modal')
    wait { modal.displayed? }
    find(:css, '#modal .modal-footer p').click
    wait { !modal.displayed? }
  end

  it 'File Upload uploads a file' do
    file = Tempfile.new(['e2e-upload', '.txt']).tap { |f| f.write('hello'); f.close }
    visit '/upload'
    @driver.file_detector = ->(args) { args.first.to_s if File.exist?(args.first.to_s) } if ENV['TARGET'] == 'saucelabs'
    find(:id, 'file-upload').send_keys(file.path)
    find(:id, 'file-submit').click
    expect(wait { find(:id, 'uploaded-files') }.text.strip).to eq File.basename(file.path)
  ensure
    file&.unlink
  end

  it 'Frames: nested frames can be traversed' do
    visit '/nested_frames'
    @driver.switch_to.frame(find(:name, 'frame-top'))
    @driver.switch_to.frame(find(:name, 'frame-middle'))
    expect(find(:id, 'content').text).to eq 'MIDDLE'
    @driver.switch_to.default_content
    @driver.switch_to.frame(find(:name, 'frame-bottom'))
    expect(find(:tag_name, 'body').text.strip).to eq 'BOTTOM'
  end

  it 'Horizontal Slider moves with arrow keys' do
    visit '/horizontal_slider'
    slider = find(:css, 'input[type=range]')
    slider.click
    slider.send_keys(:home)
    3.times { slider.send_keys(:arrow_right) }
    expect(find(:id, 'range').text).to eq '1.5'
  end

  it 'Hovers reveal the caption' do
    visit '/hovers'
    figure = @driver.find_elements(:css, '.figure').first
    @driver.action.move_to(figure).perform
    expect(figure.find_element(:css, '.figcaption h5').text).to eq 'name: user1'
  end

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

  it 'JavaScript Alerts: alert, confirm and prompt' do
    visit '/javascript_alerts'
    find(:xpath, "//button[text()='Click for JS Alert']").click
    @driver.switch_to.alert.accept
    expect(find(:id, 'result').text).to eq 'You successfully clicked an alert'

    find(:xpath, "//button[text()='Click for JS Confirm']").click
    @driver.switch_to.alert.dismiss
    expect(find(:id, 'result').text).to eq 'You clicked: Cancel'

    find(:xpath, "//button[text()='Click for JS Prompt']").click
    @driver.switch_to.alert.tap { |a| a.send_keys('Sauce') }.accept
    expect(find(:id, 'result').text).to eq 'You entered: Sauce'
  end

  it 'Key Presses reports the key' do
    visit '/key_presses'
    find(:id, 'target').send_keys(:tab)
    expect(find(:id, 'result').text).to eq 'You entered: TAB'
  end

  it 'Multiple Windows opens and switches to a new window' do
    visit '/windows'
    original = @driver.window_handle
    find(:link_text, 'Click Here').click
    wait { @driver.window_handles.size == 2 }
    @driver.switch_to.window((@driver.window_handles - [original]).first)
    wait { @driver.title == 'New Window' }
  end

  it 'Notification Messages shows a flash' do
    visit '/notification_message'
    expect(find(:id, 'flash').text).to match(/Action (successful|unsuccesful, please try again)/)
  end

  it 'Shadow DOM text is reachable through the shadow root' do
    visit '/shadowdom'
    root = find(:css, 'my-paragraph').shadow_root
    expect(root.find_element(:css, 'p')).to be_displayed
    expect(find(:css, 'my-paragraph span').text).to eq "Let's have some different text!"
  end

  it 'Sortable Data Tables sort by last name' do
    visit '/tables'
    find(:css, '#table2 thead .last-name').click
    names = -> { @driver.find_elements(:css, '#table2 tbody .last-name').map(&:text) }
    wait { names.call == names.call.sort }
  end

  it 'WYSIWYG Editor (TinyMCE) is editable' do
    visit '/tinymce'
    @driver.switch_to.frame(wait { find(:id, 'mce_0_ifr') })
    editor = find(:id, 'tinymce')
    expect(editor.text).to eq 'Your content goes here.'
    editor.click
    editor.clear
    editor.send_keys('Hello World!')
    expect(editor.text).to eq 'Hello World!'
  end

  it 'JQuery UI Menus open sub-menus on hover' do
    visit '/jqueryui/menu'
    enabled = find(:id, 'ui-id-3')
    @driver.action.move_to(enabled).perform
    # jQuery UI opens sub-menus after a short delay.
    wait { find(:id, 'ui-id-4').displayed? }
  end

  it 'Status Codes link to pages that report the code' do
    visit '/status_codes'
    find(:link_text, '404').click
    expect(find(:css, '.example p').text).to include 'This page returned a 404 status code.'
  end
end
