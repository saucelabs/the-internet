require_relative '../spec_helper'

describe 'Examples' do
  it 'Canvas reacts to clicks and typing' do
    visit '/canvas'
    canvas = find(:id, 'canvas')
    @driver.action.move_to(canvas, 50, 20).click.perform
    expect(find(:id, 'canvas-log').text).to match(/\AClicked at \d+, \d+\z/)
    @driver.action.send_keys('hello', :enter).perform
    expect(find(:id, 'canvas-log').text).to eq 'Submitted: hello'
  end
end
