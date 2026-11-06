require_relative '../spec_helper'

describe 'Examples' do
  before { visit '/network_console' }

  def logged(css)
    wait { find(:css, "#event-log li.#{css}") }.text
  end

  it 'Network & Console: makes requests that succeed and fail' do
    find(:id, 'fetch-json').click
    expect(logged('fetch-json')).to eq 'Fetched JSON: {"fruit":"apple","count":3}'
    find(:id, 'fetch-error').click
    expect(logged('fetch-error')).to eq 'Request failed with status 500'
  end

  it 'Network & Console: logs to the console and throws an error' do
    find(:id, 'log-console').click
    expect(logged('log-console')).to eq 'Logged a message, a warning and an error'
    find(:id, 'throw-error').click
    expect(logged('throw-error')).to include 'the-internet: thrown on purpose'
  end

  it 'Network & Console: reports a CSP violation' do
    find(:id, 'csp-violation').click
    expect(logged('csp-violation')).to start_with 'CSP violation: img-src'
  end
end
