require 'marcel'
require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/worksheet'
require 'zip'

module BerkeleyLibrary
  module Util
    module XLSX
      # Convenience wrapper RubyXL::Workbook
      class Spreadsheet

        # .xlsx format, a.k.a. "Office Open XML Workbook" spreadsheet
        MIME_TYPE_OOXML_WB = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.freeze

        # path to Excel worksheet file in zipped OOXML archive
        RE_EXCEL_WORKSHEET_ZIP_ENTRY = %r{^xl/worksheets/[^/.]+\.xml$}

        DEFAULT_WORKSHEET_NAME = 'Sheet1'.freeze

        attr_reader :workbook, :xlsx_path

        delegate :stream, to: :workbook

        def initialize(xlsx_path = nil)
          @workbook = xlsx_path ? ensure_xlsx_workbook!(xlsx_path) : RubyXL::Workbook.new
          @xlsx_path = xlsx_path
        end

        def save_as(new_xlsx_path)
          workbook.write(new_xlsx_path)
          @xlsx_path = new_xlsx_path
        end

        def worksheet
          @worksheet ||= workbook.worksheets[0]
        end

        def header_row
          @header_row ||= (hr = worksheet[0]) ? hr : worksheet.add_row
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

        def column_count(r_index = nil)
          if r_index
            return (row = worksheet[r_index]) ? row.size : 0
          end

          rows.inject(0) do |cc_max, r|
            r ? [r.size, cc_max].max : cc_max
          end
        end

        def ensure_column!(header)
          c_index_existing = find_column_index_by_header(header)
          return c_index_existing if c_index_existing

          c_index_next = worksheet.first_blank_column_index
          c_index_next.tap { |cc| worksheet.add_cell(0, cc, header) }
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

          # Marcel fails to recognize some OOXML files, probably due to unexpected entry order
          # and/or large entries pushing the signature it's looking for too deep into the file
          return ensure_xlsx!(xlsx_path) if Marcel::Magic.child?(mime_type, 'application/zip')

          raise ArgumentError, "Expected Excel Workbook (.xlsx), got #{mime_type}: #{xlsx_path}"
        end

        def ensure_xlsx!(zipfile_path)
          return if Zip::File.open(zipfile_path) { |zf| zf.any? { |e| e.name =~ RE_EXCEL_WORKSHEET_ZIP_ENTRY } }

          raise ArgumentError, "No Excel worksheets found in ZIP archive #{zipfile_path}"
        end
      end
    end
  end
end
