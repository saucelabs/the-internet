require_relative '../spec_helper'

describe 'Examples' do
  def button_box
    r = find(:id, 'card-button').rect
    [r.x, r.y]
  end

  it 'Visual Differences: the baseline has no changes' do
    visit '/visual_diff'
    expect(find(:id, 'active-changes').text).to eq 'Changes: none'
    expect(find(:id, 'card-title').text).to eq 'Sign up for our newsletter'
    expect(find(:id, 'card-logo')).to be_displayed
  end

  it 'Visual Differences: parameters move, recolour and hide things' do
    visit '/visual_diff'
    x, y = button_box
    visit '/visual_diff?shift=20&color=red&hide_logo=true&typo=true'
    expect(find(:id, 'active-changes').text).to eq 'Changes: shift 20px, color red, logo hidden, typo'
    expect(button_box).to eq [x + 20, y]
    expect(find(:id, 'card-button').css_value('background-color')).to match(/150, 16, 1/)
    expect(find(:id, 'card-logo')).not_to be_displayed
    expect(find(:id, 'card-title').text).to eq 'Sign up for our newsleter'
  end
end
