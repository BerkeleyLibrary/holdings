require 'marcel'
require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/worksheet'

module BerkeleyLibrary
  module Util
    module XLSX
      # Convenience wrapper RubyXL::Workbook
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

        def find_column_index_by_header(header)
          find_column_index(header_row, header)
        end

        def find_column_index_by_header!(header)
          c_index = find_column_index_by_header(header)
          return c_index if c_index

          raise ArgumentError, "#{header.inspect} column not found"
        end

        def find_column_index(row, *args)
          case args.size
          when 0
            (0...row.size).find { |c_index| yield row[c_index] }
          when 1
            find_column_index(row) { |cell| cell&.value == args[0] }
          else
            raise ArgumentError, "Wrong number of arguments (given #{args.size}, expected 0..1"
          end
        end

        def each_value(c_index, include_header: true)
          return to_enum(:each_value, c_index, include_header:) unless block_given?

          start_index = include_header ? 0 : 1
          (start_index...row_count).each do |r_index|
            yield value_at(r_index, c_index)
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

        def set_value_at(r_index, c_index, value)
          if (cell = cell_at(r_index, c_index))
            cell.change_contents(value)
          else
            worksheet.add_cell(r_index, c_index, value)
          end
        end

        def rows
          sheet_data.rows
        end

        def row_count
          sheet_data.size
        end

        def column_count(r_index = 0)
          return 0 unless (row = worksheet[r_index])

          row.size
        end

        def ensure_column!(header)
          c_index_existing = find_column_index_by_header(header)
          return c_index_existing if c_index_existing

          header_row.size.tap do |c_index_next|
            worksheet.insert_cell(0, c_index_next, header)
          end
        end

        private

        def sheet_data
          worksheet.sheet_data
        end

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
