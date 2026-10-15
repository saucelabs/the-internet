require_relative '../spec_helper'

describe 'Examples' do
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
end
