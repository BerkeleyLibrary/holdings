require 'berkeley_library/util/uris'

module BerkeleyLibrary
  module Location
    module WorldCat
      module Config
        include BerkeleyLibrary::Util::URIs

        # The environment variable from which to read the WorldCat API key and secret.
        ENV_WORLDCAT_API_KEY = 'LIT_WORLDCAT_API_KEY'.freeze
        ENV_WORLDCAT_API_SECRET = 'LIT_WORLDCAT_API_SECRET'.freeze

        # The environment variable from which to read the WorldCat base URL.
        ENV_WORLDCAT_BASE_URL = 'LIT_WORLDCAT_BASE_URL'.freeze

        # The environment variable from which to read the OCLC Token URL.
        ENV_OCLC_TOKEN_URL = 'LIT_OCLC_TOKEN_URL'.freeze

        # The default WorldCat base URL, if ENV_WORLDCAT_BASE_URL is not set.
        # DEFAULT_WORLDCAT_BASE_URL = 'https://www.worldcat.org/webservices/'.freeze
        DEFAULT_WORLDCAT_BASE_URL = 'https://americas.discovery.api.oclc.org/worldcat/search/v2/'.freeze

        # The default OCLC Token URL, if ENV_OCLC_TOKEN_URL is not set.
        DEFAULT_OCLC_TOKEN_URL = 'https://oauth.oclc.org/token'.freeze

        class << self
          include Config
        end

        # Sets the WorldCat API key and secret
        # @param value [String] the API key.
        attr_writer :api_key, :api_secret


        # Gets the WorldCat API key.
        # @return [String, nil] the WorldCat API key, or `nil` if not set.
        def api_key
          @api_key ||= default_worldcat_api_key
        end

        # Sets the WorldCat API secret.
        def api_secret
          @api_secret ||= default_worldcat_api_secret
        end

        def base_uri
          @base_uri ||= default_worldcat_base_uri
        end

        def token_uri
          @token_uri ||= default_oclc_token_uri
        end

        def base_uri=(value)
          @base_uri = uri_or_nil(value)
        end

        def token_uri=(value)
          @token_uri = uri_or_nil(value)
        end

        private

        def reset!
          %i[@api_key @base_uri].each { |v| remove_instance_variable(v) if instance_variable_defined?(v) }
        end

        def default_worldcat_api_key
          ENV[ENV_WORLDCAT_API_KEY] || rails_worldcat_api_key
        end

        def default_worldcat_api_secret
          ENV[ENV_WORLDCAT_API_SECRET] || rails_worldcat_api_secret
        end

        def default_worldcat_base_uri
          uri_or_nil(default_worldcat_base_url)
        end

        def default_oclc_token_uri
          uri_or_nil(default_oclc_token_url)
        end

        def default_worldcat_base_url
          ENV[ENV_WORLDCAT_BASE_URL] || rails_worldcat_base_url || DEFAULT_WORLDCAT_BASE_URL
        end

        def default_oclc_token_url
          ENV[ENV_OCLC_TOKEN_URL] || rails_oclc_token_url || DEFAULT_OCLC_TOKEN_URL
        end

        def rails_worldcat_base_url
          return unless (rails_config = self.rails_config)
          return unless rails_config.respond_to?(:worldcat_base_url)

          rails_config.worldcat_base_url
        end

        def rails_oclc_token_url
          return unless (rails_config = self.rails_config)
          return unless rails_config.respond_to?(:oclc_token_url)

          rails_config.oclc_token_url
        end

        def rails_worldcat_api_key
          return unless (rails_config = self.rails_config)
          return unless rails_config.respond_to?(:worldcat_api_key)

          rails_config.worldcat_api_key
        end

        def rails_config
          return unless defined?(Rails)
          return unless (app = Rails.application)

          app.config
        end
      end
    end
  end
end
