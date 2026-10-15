# HTTP contract suite: black-box checks of every example's URL, status,
# auth, redirects, flash messages and markup. It runs against any deployment:
#
#   BASE_URL=https://the-internet.herokuapp.com bundle exec rspec   # live baseline
#   BASE_URL=http://localhost:9292 bundle exec rspec                # local app (default)
#
# (run from spec/contract, or with BUNDLE_GEMFILE=spec/contract/Gemfile)
#
# Tags:
#   :writes     — changes server state (uploads, sends mail); only runs against
#                 localhost unless ALLOW_WRITES=1.
#   :unreleased — exists on main but not yet on the live site; skipped when
#                 BASE_URL is the live site.
require 'uri'
require_relative 'support/client'
require_relative 'support/snapshot'

BASE_URL = ENV.fetch('BASE_URL', 'http://localhost:9292').chomp('/')
LIVE = URI(BASE_URL).host == 'the-internet.herokuapp.com'
LOCAL = %w[localhost 127.0.0.1 0.0.0.0].include?(URI(BASE_URL).host)

module ContractHelpers
  def client
    @client ||= Client.new(BASE_URL)
  end

  def html(res)
    Nokogiri::HTML(res.body)
  end

  def path_of(location)
    URI(location).request_uri
  end
end

RSpec.configure do |config|
  config.include ContractHelpers
  config.filter_run_excluding :writes unless LOCAL || ENV['ALLOW_WRITES']
  config.filter_run_excluding :unreleased if LIVE
  config.order = :defined
end
