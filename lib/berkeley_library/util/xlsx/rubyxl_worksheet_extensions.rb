require 'rubyXL'
require 'berkeley_library/util/xlsx/rubyxl_cell_extensions'

module BerkeleyLibrary
  module Util
    module XLSX
      module RubyXLWorksheetExtensions
        def first_blank_column_index
          sheet_data.rows.inject(0) do |first_blank_c_index, row|
            trailing_blank_cells = row.cells.reverse.take_while(&:blank?)
            row_first_blank_c_index = row.size - trailing_blank_cells.size
            [first_blank_c_index, row_first_blank_c_index].max
          end
        end
      end
    end
  end
end

module RubyXL
  class Worksheet
    prepend BerkeleyLibrary::Util::XLSX::RubyXLWorksheetExtensions
  end
end
