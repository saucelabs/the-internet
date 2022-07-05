require_relative 'spec_helper'
require_relative 'pages/dynamic_loading'

describe 'Dynamic Loading' do

  before(:each) do
    @dynamic_loading = DynamicLoading.new(@driver)
  end

  it 'Example 1: Hidden Element' do
    @dynamic_loading.example(1)
    @dynamic_loading.start
    expect(@dynamic_loading.finish_text_present?).to eql true
  end

  it 'Example 2: Rendered after the fact' do
    @dynamic_loading.example(2)
    @dynamic_loading.start
    expect(@dynamic_loading.finish_text_present?).to eql true
  end

end
