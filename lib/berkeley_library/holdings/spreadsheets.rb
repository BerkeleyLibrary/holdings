require 'marcel'
require 'rubyXL'

module BerkeleyLibrary
  module Holdings
    module Spreadsheets
      class << self
        include Spreadsheets
      end

      OCLC_COL_HEADER = 'OCLC Number'.freeze

      # .xlsx format, a.k.a. "Office Open XML Workbook" spreadsheet
      MIME_TYPE_OOXML_WB = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.freeze

      def oclc_numbers_from(xlsx_path, &)
        wb = ensure_xlsx_workbook(xlsx_path)
        enumerate_oclc_numbers(wb, &)
      end

      private

      def ensure_xlsx_workbook(xlsx_path)
        # RubyXL will try to parse an Excel 95 or 97 file (which are still)
        # zip-based) but then choke when it tries to read the worksheet, so
        # we explicitly check the MIME type here
        check_mime_type!(xlsx_path)

        RubyXL::Parser.parse(xlsx_path)
      end

      def check_mime_type!(xlsx_path)
        xlsx_pathname = Pathname.new(xlsx_path)
        mime_type = Marcel::MimeType.for(xlsx_pathname)
        # TODO: test w/application/vnd.ms-excel.sheet.macroenabled.12
        return if Marcel::Magic.child?(mime_type, MIME_TYPE_OOXML_WB)

        raise ArgumentError, "Expected Excel Workbook (.xlsx), got #{mime_type}: #{xlsx_path}"
      end

      def enumerate_oclc_numbers(wb)
        return to_enum(:enumerate_oclc_numbers, wb) unless block_given?

        ws = wb.worksheets[0]
        oclc_col_index = oclc_col_index_from(ws)

        ws.each_with_index do |row, ri|
          next unless ri > 0
          next unless row
          next unless (cell = row[oclc_col_index])
          next unless (strval = strval_from(cell))

          yield strval
        end
      end

      def strval_from(cell)
        cell.value.to_s.tap do |v_str|
          return if v_str.strip == ''
        end
      end

      def oclc_col_index_from(ws)
        raise ArgumentError, 'Header row not found' unless (header_row = ws[0])
        raise ArgumentError, "#{OCLC_COL_HEADER} column not found in #{header_row.size} columns" unless
          (oclc_col_index = find_oclc_col_index(header_row))

        oclc_col_index
      end

      def find_oclc_col_index(row)
        find_column_index(row) do |cell|
          next unless cell
          next unless (v = strval_from(cell))

          v.strip == OCLC_COL_HEADER
        end
      end

      def find_column_index(row, &block)
        (0...row.size).find { |ci| block.call(row[ci]) }
      end
    end
  end
end
