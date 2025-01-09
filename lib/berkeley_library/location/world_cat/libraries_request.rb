require 'nokogiri'
require 'json'
require 'jsonpath'
require 'berkeley_library/util'
require 'berkeley_library/location/oclc_number'
require 'berkeley_library/location/world_cat/symbols'
require 'berkeley_library/location/world_cat/oclc_auth'

module BerkeleyLibrary
  module Location
    module WorldCat
      # @see https://developer.api.oclc.org/wcv2#/Member%20General%20Holdings/find-bib-holdings
      class LibrariesRequest
        include BerkeleyLibrary::Util

        JPATH_INST_ID_VALS = '$.briefRecords[*].institutionHolding.briefHoldings[*].oclcSymbol'.freeze

        attr_reader :oclc_number, :symbols

        def initialize(oclc_number, symbols: Symbols::ALL)
          @oclc_token = OCLCAuth.instance
          @oclc_number = OCLCNumber.ensure_oclc_number!(oclc_number)
          @symbols = Symbols.ensure_valid!(symbols)
        end

        def uri
          @uri ||= URIs.append(libraries_base_uri)
        end

        def params
          @params ||= {
            'oclcNumber' => oclc_number,
            'heldBySymbol' => symbols.join(',')
          }
        end

        def headers
          @headers ||= {
            'Authorization' => "Bearer #{oclc_token.access_token}"
          }
        end

        def execute
          response_body = URIs.get(uri, params:, headers:, log: false)
          inst_symbols_from(response_body)
        end

        private

        # OCLC changed to a token-based authentication system
        # separating auth from request
        def oclc_token
          @oclc_token ||= OCLCAuth.new
        end

        def libraries_base_uri
          URIs.append(Config.base_uri, 'bibs-holdings')
        end

        def inst_symbols_from(json)
          path = JsonPath.new(JPATH_INST_ID_VALS)
          path.on(json)
        end
      end
    end
  end
end
