require 'rubyXL'

module BerkeleyLibrary
  module Holdings
    module Spreadsheets
      class << self
        include Spreadsheets
      end

      OCLC_COL_HEADER = 'OCLC Number'

      def oclc_numbers_from(xlsx_path)
        wb = RubyXL::Parser.parse(xlsx_path)
        ws = wb.worksheets[0]
        raise ArgumentError, 'Header row not found' unless (header_row = ws[0])
        raise ArgumentError, "#{OCLC_COL_HEADER} column not found in #{row.size} columns" unless (oclc_col_index = find_oclc_col_index(header_row))

        ws.each_with_index do |row, ri|
          next if ri == 0
          next unless (cell = row[oclc_col_index])
          next unless (v = cell.value)

          yield v if block_given?
        end
      end

      private

      def find_oclc_col_index(row)
        find_column_index(row) do |cell|
          next unless cell
          next unless (v = cell.value)
          next unless v.respond_to?(:strip)

          v.strip == OCLC_COL_HEADER
        end
      end

      def find_column_index(row, &block)
        (0...row.size).find do |ci|
          next unless (cell = row[ci])

          block.call(cell.value)
        end
      end
    end
  end
end
