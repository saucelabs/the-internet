require_relative '../spec_helper'

describe 'Examples' do
  it 'Horizontal Slider moves with arrow keys' do
    visit '/horizontal_slider'
    slider = find(:css, 'input[type=range]')
    slider.click
    slider.send_keys(:home)
    3.times { slider.send_keys(:arrow_right) }
    expect(find(:id, 'range').text).to eq '1.5'
  end
end
