require 'berkeley_library/logging'
require 'berkeley_library/util'
require 'berkeley_library/holdings/world_cat/symbols'

module BerkeleyLibrary
  module Holdings
    module WorldCat
      module Lookup
        include BerkeleyLibrary::Util
        include BerkeleyLibrary::Logging

        class << self
          include Lookup
        end
      end
    end
  end
end
