require 'spec_helper'

module BerkeleyLibrary
  module Util
    module XLSX
      describe RubyXLWorksheetExtensions do
        describe :first_blank_column_index do
          it 'returns 0 for an empty spreadsheet' do
            workbook = RubyXL::Workbook.new
            worksheet = workbook.worksheets[0]
            c_index_expected = 0

            c_index_actual = worksheet.first_blank_column_index
            expect(c_index_actual).to eq(c_index_expected)
          end

          it 'returns the first blank column for a justified sheet' do
            workbook = RubyXL::Parser.parse('spec/data/excel/sparse-table.xlsx')
            worksheet = workbook.worksheets[0]
            c_index_expected = 3

            c_index_actual = worksheet.first_blank_column_index
            expect(c_index_actual).to eq(c_index_expected)
          end

          it 'skips intermediate blank columns' do
            workbook = RubyXL::Parser.parse('spec/data/excel/oclc-numbers.xlsx')
            worksheet = workbook.worksheets[0]
            row_count = worksheet.sheet_data.size

            cc_original = worksheet[0].size
            cc_inserted = 2
            cc_inserted.times { worksheet.insert_column(cc_original - 1) }
            cc_after_insert = worksheet[0].size

            cc_appended = 3
            cc_appended.times { worksheet.insert_column(cc_after_insert) }

            (0...row_count).step(3).each do |r_index|
              worksheet.add_cell(r_index, cc_after_insert, ' ')
            end
            (0...row_count).step(7).each do |r_index|
              worksheet.add_cell(r_index, cc_after_insert, "\t")
            end

            c_index_expected = cc_after_insert

            c_index_actual = worksheet.first_blank_column_index
            expect(c_index_actual).to eq(c_index_expected)
          end

          it 'is reasonably performant for large spreadsheets' do
            workbook = RubyXL::Workbook.new
            worksheet = workbook.worksheets[0]

            # NOTE: tested with up to 100_000, but while
            # first_blank_column_index is still reasonably fast,
            # test data setup is slow (~ 10 seconds)
            num_rows = 5000
            value_cols = 5
            blank_cols = 5
            c_index_expected = value_cols

            num_rows.times do |r_index|
              value_cols.times do |c_index|
                worksheet.add_cell(r_index, c_index, [r_index, c_index].join(', '))
              end
              blank_cols.times do |offset|
                worksheet.add_cell(r_index, value_cols + offset, ' ')
              end
            end

            start_time = Time.now
            c_index_actual = worksheet.first_blank_column_index
            time_taken = Time.now - start_time
            expect(time_taken).to be < 1

            expect(c_index_actual).to eq(c_index_expected)
          end
        end

        it 'handles nil rows' do
          xlsx_path = 'spec/data/excel/nil-rows.xlsx'
          workbook = RubyXL::Parser.parse(xlsx_path)
          worksheet = workbook.worksheets[0]

          c_index_expected = 4
          c_index_actual = worksheet.first_blank_column_index
          expect(c_index_actual).to eq(c_index_expected)
        end
      end
    end
  end
end
