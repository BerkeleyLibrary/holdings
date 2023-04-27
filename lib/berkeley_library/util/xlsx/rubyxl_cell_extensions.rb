require 'rubyXL'

module BerkeleyLibrary
  module Util
    module XLSX
      module RubyXLCellExtensions
        # Workaround for https://github.com/weshatheleopard/rubyXL/issues/441
        def initialize(params = nil)
          super

          return unless params.respond_to?(:[])

          @worksheet ||= params[:worksheet]
          self.row ||= params[:row] # NOTE: not an instance variable
        end

        def blank?
          return true if value.nil?

          value.respond_to?(:strip) && value.strip.empty?
        end
      end
    end
  end
end

module RubyXL
  class Cell
    prepend BerkeleyLibrary::Util::XLSX::RubyXLCellExtensions
  end
end
