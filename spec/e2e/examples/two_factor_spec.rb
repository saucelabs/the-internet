require_relative '../spec_helper'

describe 'Examples' do
  it 'Two-Factor Login takes a one-time code in a password field' do
    visit '/two_factor'
    find(:id, 'username').send_keys('tomsmith')
    find(:id, 'password').send_keys('SuperSecretPassword!')
    find(:css, 'button[type=submit]').click
    code = wait { find(:id, 'otp-code') }.text
    find(:id, 'code').send_keys(code)
    find(:css, 'button[type=submit]').click
    expect(wait { find(:id, 'flash') }.text).to include 'You logged in with two-factor authentication!'
  end
end
