require_relative '../spec_helper'

describe 'Examples' do
  it 'Shadow DOM text is reachable through the shadow root' do
    visit '/shadowdom'
    root = find(:css, 'my-paragraph').shadow_root
    expect(root.find_element(:css, 'p')).to be_displayed
    expect(find(:css, 'my-paragraph span').text).to eq "Let's have some different text!"
  end
end
