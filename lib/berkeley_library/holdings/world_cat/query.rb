require 'berkeley_library/holdings/world_cat/symbols'

module BerkeleyLibrary
  module Holdings
    module WorldCat
      class Query
        attr_reader :oclc_number, :symbols

        def initialize(oclc_number, symbols = Symbols::ALL)
          @oclc_number = ensure_oclc_number!(oclc_number)

          @symbols = Symbols.ensure_valid!(symbols)
        end

        private

        def ensure_oclc_number!(oclc_number)
          raise ArgumentError, 'OCLC number cannot be nil' if oclc_number.nil?
          raise ArgumentError, "OCLC number #{oclc_number.inspect} is not a string" unless oclc_number.is_a?(String)
          raise ArgumentError, 'OCLC number cannot be empty' if oclc_number == ''
          raise ArgumentError, "OCLC number #{oclc_number.inspect} must not be blank" if oclc_number.strip == ''

          oclc_number
        end
      end
    end
  end
end
