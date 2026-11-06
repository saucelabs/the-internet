require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/iframes_advanced' }

  it 'Advanced Iframes: works inside a sandboxed frame the page cannot read' do
    expect(wait { find(:id, 'parent-access').text }).to eq "The page can't read the sandboxed frame"
    @driver.switch_to.frame(find(:id, 'sandboxed-frame'))
    expect(find(:id, 'frame-title').text).to eq 'Frame: sandboxed'
    find(:id, 'send-message').click
    @driver.switch_to.default_content
    expect(wait { find(:id, 'message-log').text }).to eq 'Message from the sandboxed frame: hello'
  end

  it 'Advanced Iframes: types into a srcdoc frame' do
    @driver.switch_to.frame(find(:id, 'srcdoc-frame'))
    expect(find(:id, 'srcdoc-text').text).to eq 'Hello from srcdoc'
    find(:id, 'srcdoc-input').send_keys('typed')
    expect(find(:id, 'srcdoc-input').attribute('value')).to eq 'typed'
  end

  it 'Advanced Iframes: switches to a frame inside a shadow root' do
    frame = find(:id, 'frame-host').shadow_root.find_element(:css, '#shadow-frame')
    @driver.switch_to.frame(frame)
    expect(find(:id, 'frame-title').text).to eq 'Frame: shadow'
  end
end
