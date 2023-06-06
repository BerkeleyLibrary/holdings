require 'berkeley_library/location/world_cat/symbols'

module BerkeleyLibrary
  module Location
    class LocationResult
      attr_reader :oclc_number, :wc_symbols, :ht_record_url, :wc_error, :ht_error

      def initialize(oclc_number, wc_symbols: [], wc_error: nil, ht_record_url: nil, ht_error: nil)
        @oclc_number = oclc_number
        @wc_symbols = wc_symbols
        @wc_error = wc_error
        @ht_record_url = ht_record_url
        @ht_error = ht_error
      end

      def nrlf?
        @has_nrlf ||= wc_symbols.intersection(WorldCat::Symbols::NRLF).any?
      end

      def srlf?
        @has_srlf ||= wc_symbols.intersection(WorldCat::Symbols::SRLF).any?
      end

      def uc_symbols
        @uc_symbols ||= wc_symbols.intersection(WorldCat::Symbols::UC)
      end
    end
  end
end
