require 'berkeley_library/util/uris'

module BerkeleyLibrary
  module Holdings
    module WorldCat
      module Config
        include BerkeleyLibrary::Util::URIs

        # The environment variable from which to read the WorldCat API key.
        ENV_WORLDCAT_API_KEY = 'LIT_WORLDCAT_API_KEY'.freeze

        # The environment variable from which to read the WorldCat base URL.
        ENV_WORLDCAT_BASE_URL = 'LIT_WORLDCAT_BASE_URL'.freeze

        # The default WorldCat base URL, if ENV_WORLDCAT_BASE_URL is not set.
        DEFAULT_WORLDCAT_BASE_URL = 'https://www.worldcat.org/webservices/'.freeze

        class << self
          include Config
        end

        # Sets the WorldCat API key.
        # @param value [String] the API key.
        attr_writer :api_key

        # Gets the WorldCat API key.
        # @return [String, nil] the WorldCat API key, or `nil` if not set.
        def api_key
          @api_key ||= default_worldcat_api_key
        end

        def base_uri
          @base_uri ||= default_worldcat_base_uri
        end

        def base_uri=(value)
          @base_uri = uri_or_nil(value)
        end

        private

        def reset!
          %i[@api_key @base_uri].each { |v| remove_instance_variable(v) if instance_variable_defined?(v) }
        end

        def default_worldcat_api_key
          ENV[ENV_WORLDCAT_API_KEY] || rails_worldcat_api_key
        end

        def default_worldcat_base_uri
          return unless (base_url = default_worldcat_base_url)

          uri_or_nil(base_url)
        end

        def default_worldcat_base_url
          ENV[ENV_WORLDCAT_BASE_URL] || rails_worldcat_base_url || DEFAULT_WORLDCAT_BASE_URL
        end

        def rails_worldcat_base_url
          return unless (rails_config = self.rails_config)
          return unless rails_config.respond_to?(:worldcat_base_url)

          rails_config.worldcat_base_url
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
