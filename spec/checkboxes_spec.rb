require_relative 'spec_helper'
require_relative 'pages/checkboxes'

describe 'Checkboxes' do
  before(:each) do
    @checkboxes = Checkboxes.new(@driver)
  end

  it 'Example 1: Check a checkbox' do
    @checkboxes.select_checkbox(0)
    expect(@checkboxes.is_checked?(0)).to eql(true)
  end

  it 'Example 2: Uncheck a checkbox' do
    @checkboxes.select_checkbox(1)
    expect(@checkboxes.is_checked?(1)).to eql(false )
  end
end
