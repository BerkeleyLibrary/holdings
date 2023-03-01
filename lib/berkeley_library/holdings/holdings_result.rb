module BerkeleyLibrary
  module Holdings
    class HoldingsResult
      attr_reader :wc_symbols, :ht_record_url, :wc_error, :ht_error

      def initialize(wc_symbols: [], wc_error: nil, ht_record_url: nil, ht_error: nil)
        @wc_symbols = wc_symbols
        @wc_error = wc_error
        @ht_record_url = ht_record_url
        @ht_error = ht_error
      end
    end
  end
end
