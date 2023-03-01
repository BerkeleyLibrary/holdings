require 'berkeley_library/logging'
require 'berkeley_library/holdings/oclc_number'
require 'berkeley_library/holdings/holdings_result'
require 'berkeley_library/holdings/world_cat/libraries_request'
require 'berkeley_library/holdings/world_cat/symbols'
require 'berkeley_library/holdings/hathi_trust/record_url_request'

module BerkeleyLibrary
  module Holdings
    class HoldingsRequest
      include BerkeleyLibrary::Logging

      attr_reader :oclc_number, :wc_req, :ht_req

      MSG_EMPTY_REQ = 'Holdings request must be for WorldCat institution symbols, HathiTrust record URL, or both'.freeze

      def initialize(oclc_number, wc_symbols: WorldCat::Symbols::ALL, include_ht: true)
        @oclc_number = OCLCNumber.ensure_oclc_number!(oclc_number)

        @wc_req = wc_req_for(oclc_number, wc_symbols)
        @ht_req = ht_req_for(oclc_number, include_ht)

        raise ArgumentError, MSG_EMPTY_REQ unless wc_req || ht_req
      end

      def execute
        params = {}.tap do |res|
          populate_wc_result(res)
          populate_ht_result(res)
        end

        HoldingsResult.new(**params)
      end

      def wc_symbols
        wc_req&.symbols
      end

      def include_ht?
        !ht_req.nil?
      end

      private

      # TODO: something less clunky
      def populate_wc_result(result)
        return unless wc_req

        result[:wc_symbols] = wc_req.execute
      rescue StandardError => e
        logger.warn("Error retrieving WorldCat holdings for #{oclc_number.inspect}, symbols: #{wc_symbols.inspect}", e)

        result[:wc_error] = e
      end

      # TODO: something less clunky
      def populate_ht_result(result)
        return unless ht_req

        result[:ht_record_url] = ht_req.execute
      rescue StandardError => e
        logger.warn("Error retrieving HathiTrust record URL for #{oclc_number.inspect}", e)

        result[:ht_error] = e
      end

      def ht_req_for(oclc_number, include_ht)
        return unless include_ht

        HathiTrust::RecordUrlRequest.new(oclc_number)
      end

      def wc_req_for(oclc_number, symbols)
        return unless symbols && symbols.any?

        WorldCat::LibrariesRequest.new(oclc_number, symbols:)
      end

    end
  end
end
