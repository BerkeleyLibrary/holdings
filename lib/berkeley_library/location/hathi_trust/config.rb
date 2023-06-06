require 'berkeley_library/util'

module BerkeleyLibrary
  module Location
    module HathiTrust
      module Config
        include BerkeleyLibrary::Util::URIs

        ENV_HATHITRUST_BASE_URL = 'LIT_HATHITRUST_BASE_URL'.freeze

        # The default HathiTrust base URL, if ENV_HATHITRUST_BASE_URL is not set.
        DEFAULT_HATHITRUST_BASE_URL = 'https://catalog.hathitrust.org/api/'.freeze

        class << self
          include Config
        end

        def base_uri
          @base_uri ||= default_hathitrust_base_uri
        end

        def base_uri=(value)
          @base_uri = uri_or_nil(value)
        end

        private

        def reset!
          remove_instance_variable(:@base_uri) if instance_variable_defined?(:@base_uri)
        end

        def default_hathitrust_base_uri
          uri_or_nil(default_hathitrust_base_url)
        end

        def default_hathitrust_base_url
          ENV[ENV_HATHITRUST_BASE_URL] || rails_hathitrust_base_url || DEFAULT_HATHITRUST_BASE_URL
        end

        def rails_hathitrust_base_url
          return unless (rails_config = self.rails_config)
          return unless rails_config.respond_to?(:hathitrust_base_url)

          rails_config.hathitrust_base_url
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
