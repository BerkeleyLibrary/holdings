require 'marcel'
require 'rubyXL'
require 'rubyXL/convenience_methods/worksheet'

module BerkeleyLibrary
  module Util
    module XLSX
      class Spreadsheet

        # .xlsx format, a.k.a. "Office Open XML Workbook" spreadsheet
        MIME_TYPE_OOXML_WB = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.freeze

        DEFAULT_WORKSHEET_NAME = 'Sheet1'.freeze

        attr_reader :workbook, :xlsx_path

        def initialize(xlsx_path = nil)
          @workbook = xlsx_path ? ensure_xlsx_workbook!(xlsx_path) : RubyXL::Workbook.new
          @xlsx_path = xlsx_path
        end

        def save_as(new_xlsx_path)
          workbook.write(new_xlsx_path)
          @xlsx_path = new_xlsx_path
        end

        def worksheet
          @worksheet ||= ensure_worksheet!
        end

        def header_row
          @header_row ||= ensure_header_row!
        end

        def find_header_column_index(header)
          find_column_index(header_row, header)
        end

        def find_header_column_index!(header)
          cindex = find_header_column_index(header)
          return cindex if cindex

          raise ArgumentError, "#{header.inspect} column not found"
        end

        def find_column_index(row, *args)
          case args.size
          when 0
            (0...row.size).find { |ci| yield row[ci] }
          when 1
            find_column_index(row) { |cell| cell&.value == args[0] }
          else
            raise ArgumentError, "Wrong number of arguments (given #{args.size}, expected 0..1"
          end
        end

        def each_value(col_index, include_header: true)
          return to_enum(:each_value, col_index, include_header:) unless block_given?

          start_index = include_header ? 0 : 1
          (start_index...row_count).each do |r_index|
            yield value_at(r_index, col_index)
          end
        end

        def ensure_column!(header)
          cindex_existing = find_header_column_index(header)
          return cindex_existing if cindex_existing

          header_row.size.tap do |cindex_next|
            worksheet.insert_cell(0, cindex_next, header)
          end
        end

        def cell_at(r_index, c_index)
          return unless (row = worksheet[r_index])

          row[c_index]
        end

        def value_at(r_index, c_index)
          return unless (cell = cell_at(r_index, c_index))

          cell.value
        end

        def row_count
          worksheet.sheet_data.size
        end

        def column_count(r_index = 0)
          return 0 unless (row = worksheet[r_index])

          row.size
        end

        private

        def ensure_xlsx_workbook!(xlsx_path)
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

        def ensure_worksheet!
          workbook.worksheets[0] || workbook.add_worksheet(DEFAULT_WORKSHEET_NAME)
        end

        def ensure_header_row!
          hr = worksheet[0]
          return hr if hr

          worksheet.add_row
        end
      end
    end
  end
end
