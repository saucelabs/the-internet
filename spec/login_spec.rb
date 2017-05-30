require_relative 'spec_helper'

describe 'Login' do

  it 'succeeded' do
    @driver.get ENV['base_url'] + '/login'
    @driver.find_element(id: 'username').send_keys 'tomsmith'
    @driver.find_element(id: 'password').send_keys 'SuperSecretPassword!'
    @driver.find_element(css: '#login button').click
    Selenium::WebDriver::Wait.new(timeout: 2).until do
      @driver.find_element(css: '.flash').displayed?
    end
    expect(@driver.find_element(css: '.flash.success').displayed?).to eql true
  end

  it 'failed' do
    @driver.get ENV['base_url'] + '/login'
    @driver.find_element(id: 'username').send_keys 'tomsmith'
    @driver.find_element(id: 'password').send_keys 'bad password'
    @driver.find_element(css: '#login button').click
    Selenium::WebDriver::Wait.new(timeout: 2).until do
      @driver.find_element(css: '.flash').displayed?
    end
    expect(@driver.find_element(css: '.flash.error').displayed?).to eql true
  end

end
