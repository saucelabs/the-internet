require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/svg' }

  it 'SVG: finds bars with XPath and clicks one' do
    bars = @driver.find_elements(:xpath, "//*[local-name()='svg']//*[local-name()='rect']")
    expect(bars.map { |b| b.attribute('data-label') }).to eq %w[Apples Bananas Cherries]
    bars[1].click
    expect(find(:id, 'result').text).to eq 'Selected Bananas: 180'
    expect(bars[1].attribute('fill')).to eq '#f55524'
  end

  it 'SVG: clicks a circle and reads SVG text' do
    find(:css, '#chart circle').click
    expect(find(:css, '#chart #circle-label').text).to eq 'Clicked'
    expect(find(:id, 'result').text).to eq 'Circle is red'
  end
end
