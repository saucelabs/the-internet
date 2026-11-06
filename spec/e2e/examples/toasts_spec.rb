require_relative '../spec_helper'

describe 'Examples' do
  it 'Toasts: a toast hides itself after the set time' do
    visit '/toasts?duration=1500'
    expect(find(:id, 'duration').attribute('value')).to eq '1500'
    find(:id, 'success-toast').click
    toast = find(:css, '#toasts .toast-success')
    expect(toast.text).to include 'Saved successfully'
    wait(5) { @driver.find_elements(:css, '#toasts .toast').empty? }
  end

  it 'Toasts: with time 0 a toast stays until closed' do
    visit '/toasts?duration=0'
    find(:id, 'error-toast').click
    find(:id, 'info-toast').click
    sleep 1
    expect(@driver.find_elements(:css, '#toasts .toast').size).to eq 2
    find(:css, '#toast-1 .toast-close').click
    expect(@driver.find_elements(:css, '#toasts .toast').map { |t| t.attribute('id') }).to eq ['toast-2']
    expect(find(:id, 'toast-count').text).to eq 'Toasts shown: 2'
  end
end
