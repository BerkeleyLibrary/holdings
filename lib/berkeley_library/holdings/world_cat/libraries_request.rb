require 'nokogiri'
require 'berkeley_library/util'
require 'berkeley_library/holdings/oclc_number'
require 'berkeley_library/holdings/world_cat/symbols'

module BerkeleyLibrary
  module Holdings
    module WorldCat
      # @see https://developer.api.oclc.org/wcv1#/Holdings
      class LibrariesRequest
        include BerkeleyLibrary::Util

        XPATH_INST_ID_VALS = '/holdings/holding/institutionIdentifier/value'.freeze

        attr_reader :oclc_number, :symbols

        def initialize(oclc_number, symbols: Symbols::ALL)
          @oclc_number = OCLCNumber.ensure_oclc_number!(oclc_number)
          @symbols = Symbols.ensure_valid!(symbols)
        end

        def uri
          @uri ||= URIs.append(holdings_base_uri, oclc_number)
        end

        # TODO: Check that this works w/more than 10 results
        #       See https://developer.api.oclc.org/wcv1#/Holdings
        def params
          @params ||= {
            'oclcsymbol' => symbols.join(','),
            'servicelevel' => 'full',
            'frbrGrouping' => 'off',
            'wskey' => Config.api_key
          }
        end

        def execute
          response_body = URIs.get(uri, params:, log: false)
          holdings_syms = holdings_from(response_body)
          holdings_syms.select { |sym| symbols.include?(sym) } # just in case
        end

        private

        def holdings_base_uri
          URIs.append(Config.base_uri, 'catalog', 'content', 'libraries')
        end

        def holdings_from(xml)
          xml_doc = Nokogiri::XML(xml)
          id_vals = xml_doc.xpath(XPATH_INST_ID_VALS)
          id_vals.filter_map { |value| value.text.strip }
        end
      end
    end
  end
end
