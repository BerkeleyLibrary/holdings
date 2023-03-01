module BerkeleyLibrary
  module Holdings
    class HoldingsResult
      attr_reader :wc_symbols, :ht_record_url

      def initialize(wc_symbols, ht_record_url)
        @wc_symbols = wc_symbols ? wc_symbols.uniq : []
        @ht_record_url = ht_record_url
      end
    end
  end
end
