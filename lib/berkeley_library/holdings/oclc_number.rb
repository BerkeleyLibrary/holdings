module BerkeleyLibrary
  module Holdings
    module OCLCNumber
      class << self
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
