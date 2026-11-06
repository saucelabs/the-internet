require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/form_validation' }

  def fill(fields)
    fields.each do |id, value|
      find(:id, id).clear
      find(:id, id).send_keys(value)
    end
  end

  it 'Form Validation: the browser blocks an invalid form' do
    find(:css, '#signup button[type=submit]').click
    expect(find(:id, 'username').property('validity')['valueMissing']).to be true
    expect(find(:id, 'username').property('validationMessage')).not_to be_empty
    fill('username' => 'Not Valid!', 'email' => 'nope', 'age' => '12')
    expect(find(:id, 'username').property('validity')['patternMismatch']).to be true
    expect(find(:id, 'email').property('validity')['typeMismatch']).to be true
    expect(find(:id, 'age').property('validity')['rangeUnderflow']).to be true
    expect(find(:id, 'result').text).to eq ''
  end

  it 'Form Validation: shows an error from the server, then succeeds' do
    fill('username' => 'tomsmith', 'email' => 'tom@example.com', 'age' => '30', 'password' => 'longenough')
    find(:id, 'terms').click
    find(:css, '#signup button[type=submit]').click
    expect(wait { find(:id, 'username-error').text.then { |t| t unless t.empty? } }).to eq 'Username is already taken'
    expect(find(:id, 'username').attribute('aria-invalid')).to eq 'true'
    fill('username' => 'ana')
    find(:css, '#signup button[type=submit]').click
    wait { find(:id, 'result').text == 'Account created for ana' }
    expect(find(:id, 'username-error').text).to eq ''
  end
end
