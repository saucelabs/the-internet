require_relative '../spec_helper'

describe 'Examples' do
  it 'A/B Testing shows a heading' do
    visit '/abtest'
    expect(find(:css, '.example h3').text).to match(/A\/B Test|No A\/B Test/)
  end
end
