module BerkeleyLibrary
  module Holdings
    module WorldCat
      module Symbols
        NRLF = %w[ZAP ZAPSP].freeze
        SRLF = %w[HH0 ZAS ZASSP].freeze
        RLF = (NRLF + SRLF).freeze

        UC = %w[CLU CRU CUI CUN CUS CUT CUV CUX CUY CUZ MERUC].freeze
        ALL = (RLF + UC).freeze

        class << self
          include Symbols
        end

        def valid?(sym)
          ALL.include?(sym)
        end

        def ensure_valid!(symbols)
          raise ArgumentError, "Not a list of institution symbols: #{symbols.inspect}" unless array_like?(symbols)
          raise ArgumentError, "No institution symbols provided" if symbols.empty?

          return symbols unless (invalid = symbols.reject { |s| Symbols.valid?(s) }).any?

          raise ArgumentError, "Invalid institution symbol(s): #{invalid.map(&:inspect).join(', ')}"
        end

        private

        def array_like?(a)
          [:reject, :empty?].all? { |m| a.respond_to?(m) }
        end
      end
    end
  end
end
