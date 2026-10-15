require_relative '../spec_helper'

describe 'Examples' do
  it 'Hovers reveal the caption' do
    visit '/hovers'
    figure = @driver.find_elements(:css, '.figure').first
    @driver.action.move_to(figure).perform
    expect(figure.find_element(:css, '.figcaption h5').text).to eq 'name: user1'
  end
end
