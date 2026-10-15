require_relative '../spec_helper'

describe 'Examples' do
  it 'Frames: nested frames can be traversed' do
    visit '/nested_frames'
    @driver.switch_to.frame(find(:name, 'frame-top'))
    @driver.switch_to.frame(find(:name, 'frame-middle'))
    expect(find(:id, 'content').text).to eq 'MIDDLE'
    @driver.switch_to.default_content
    @driver.switch_to.frame(find(:name, 'frame-bottom'))
    expect(find(:tag_name, 'body').text.strip).to eq 'BOTTOM'
  end
end
