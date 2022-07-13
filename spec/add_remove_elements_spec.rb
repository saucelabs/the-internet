require_relative 'spec_helper'
require_relative 'pages/add_remove_elements'

describe 'Add/Remove Elements' do
  before(:each) do
    @add_remove_elements = AddRemoveElements.new(@driver)
  end

  it 'Example 1: Add an element' do
    @add_remove_elements.add_element
    expect(@add_remove_elements.delete_button_present?).to eql true
  end

  it 'Example 2: Delete and element after adding it' do
    @add_remove_elements.add_element
    expect(@add_remove_elements.delete_button_present?).to eql true
    @add_remove_elements.delete
    expect(@add_remove_elements.delete_button_not_present?).to eql true
  end
end
