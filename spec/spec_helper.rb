# ------------------------------------------------------------
# Simplecov

require 'colorize'
require 'simplecov' if ENV['COVERAGE']

# ------------------------------------------------------------
# RSpec

require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes' # Directory for storing cassettes
  config.hook_into :webmock # Use WebMock for HTTP request interception
  config.ignore_localhost = true # Allow localhost connections without VCR
  config.configure_rspec_metadata! # Automatically tag RSpec examples with VCR metadata
  
  # Optionally, filter sensitive data (like API keys) from cassettes
  config.filter_sensitive_data('<API_KEY>') { ENV['API_KEY'] }
  config.filter_sensitive_data('<API_SECRET>') { ENV['API_SECRET'] }
  
  # Allow external connections to specific URLs if needed
  config.allow_http_connections_when_no_cassette = true

  # Only record new cassettes when we explicitly allow it
  config.default_cassette_options = { record: :once }
end

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.before { WebMock.disable_net_connect!(allow_localhost: true) }
  config.after { WebMock.allow_net_connect! }
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# ------------------------------------------------------------
# Code under test

require 'berkeley_library/location'
require 'berkeley_library/util/xlsx'
