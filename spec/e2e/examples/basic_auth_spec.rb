require_relative '../spec_helper'

describe 'Examples' do
  it 'Basic Auth accepts credentials in the URL', unsupported: { 'safari' => 'Safari ignores credentials in URLs' } do
    uri = URI(ENV['BASE_URL'])
    @driver.get "#{uri.scheme}://admin:admin@#{uri.host}:#{uri.port}/basic_auth"
    expect(find(:css, '.example p').text).to include 'Congratulations!'
  end
end
