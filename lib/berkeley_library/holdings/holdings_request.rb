require 'berkeley_library/holdings/oclc_number'
require 'berkeley_library/holdings/holdings_result'
require 'berkeley_library/holdings/world_cat/holdings_request'
require 'berkeley_library/holdings/world_cat/symbols'
require 'berkeley_library/holdings/hathi_trust/record_url_request'

module BerkeleyLibrary
  module Holdings
    class HoldingsRequest

      attr_reader :oclc_number, :wc_req, :ht_req

      MSG_EMPTY_REQ = 'Holdings request must be for WorldCat institution symbols, HathiTrust record URL, or both'.freeze

      def initialize(oclc_number, wc_symbols: WorldCat::Symbols::ALL, include_ht: true)
        @oclc_number = OCLCNumber.ensure_oclc_number!(oclc_number)

        @wc_req = wc_req_for(oclc_number, wc_symbols)
        @ht_req = ht_req_for(oclc_number, include_ht)

        raise ArgumentError, MSG_EMPTY_REQ unless wc_req || ht_req
      end

      def execute
        wc_symbols = (wc_req.execute if wc_req)
        ht_record_url = (ht_req.execute if ht_req)

        HoldingsResult.new(wc_symbols, ht_record_url)
      end

      def wc_symbols
        wc_req&.symbols
      end

      def include_ht?
        !ht_req.nil?
      end

      def wc_uri
        wc_req&.uri
      end

      def ht_uri
        ht_req&.uri
      end

      private

      def ht_req_for(oclc_number, include_ht)
        return unless include_ht

        HathiTrust::RecordUrlRequest.new(oclc_number)
      end

      def wc_req_for(oclc_number, symbols)
        return unless symbols && symbols.any?

        WorldCat::HoldingsRequest.new(oclc_number, symbols:)
      end

    end
  end
end
