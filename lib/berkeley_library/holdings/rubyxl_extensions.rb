require 'rubyXL'

module BerkeleyLibrary
  module Holdings
    module RubyXLExtensions
      module CellExtensions
        # Workaround for https://github.com/weshatheleopard/rubyXL/issues/441
        def initialize(params = nil)
          super

          return unless params.respond_to?(:[])

          @worksheet ||= params[:worksheet]
          self.row ||= params[:row] # NOTE: not an instance variable
        end
      end
    end
  end
end

module RubyXL
  class Cell
    prepend BerkeleyLibrary::Holdings::RubyXLExtensions::CellExtensions
  end
end
