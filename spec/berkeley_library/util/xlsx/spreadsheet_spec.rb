require 'spec_helper'

module BerkeleyLibrary
  module Util
    module XLSX

      describe Spreadsheet do
        describe :new do
          context 'success' do
            it 'opens an XLSX spreadsheet' do
              path = 'spec/data/excel/oclc-numbers.xlsx'
              ss = Spreadsheet.new(path)
              expect(ss.xlsx_path).to eq(path)

              header_row = ss.header_row
              expect(header_row).not_to be_nil

              cells = [0, 1].map { |ci| header_row[ci] }
              values = cells.map(&:value)
              expect(values).to contain_exactly('OCLC Number', 'MMSID')
            end

            it 'creates a new, empty spreadsheet' do
              ss = Spreadsheet.new
              ws = ss.worksheet
              expect(ws).not_to be_nil
              expect(ws[0]).to be_nil
            end
          end

          context 'failure' do
            it 'rejects an Excel 95 (.xls) workbook' do
              path = 'spec/data/excel/bad/oclc-numbers-excel95.xls'

              expect { Spreadsheet.new(path) }
                .to raise_error(ArgumentError)
            end

            it 'rejects an Excel 97 (.xls) workbook' do
              path = 'spec/data/excel/bad/oclc-numbers-excel97.xls'

              expect { Spreadsheet.new(path) }
                .to raise_error(ArgumentError)
            end

            it 'rejects an Excel 95 workbook renamed to .xlsx' do
              path = 'spec/data/excel/bad/oclc-numbers-excel95-as-xlsx.xlsx'

              expect { Spreadsheet.new(path) }
                .to raise_error(ArgumentError)
            end
          end
        end

        context 'with data' do
          let(:ss) { Spreadsheet.new('spec/data/excel/oclc-numbers.xlsx') }
          let(:oclc_numbers_expected) { File.readlines('spec/data/excel/oclc_numbers_expected.txt', chomp: true) }

          describe :find_column_index do
            it 'finds the column index for a cell value' do
              midpoint = oclc_numbers_expected.size / 2
              value = oclc_numbers_expected[midpoint].to_i
              row = ss.worksheet[midpoint + 1] # header offset
              c_index = ss.find_column_index(row, value)
              expect(c_index).to eq(0)
            end

            it 'finds the column index for a matching cell' do
              midpoint = oclc_numbers_expected.size / 2
              cell_value = oclc_numbers_expected[midpoint]
              cell_value_i = cell_value.to_i
              row = ss.worksheet[midpoint + 1] # header offset
              c_index = ss.find_column_index(row) do |cell|
                cell.value == cell_value_i
              end
              expect(c_index).to eq(0)
            end

            it 'raises ArgumentError if passed too many arguments' do
              row = ss.worksheet[0]
              expect { ss.find_column_index(row, 2, 3) }.to raise_error(ArgumentError)
            end

            it 'raises LocalJumpError if no value or block given' do
              row = ss.worksheet[0]
              expect { ss.find_column_index(row) }.to raise_error(LocalJumpError)
            end
          end

          describe :find_column_index_by_header do
            it 'finds the column index' do
              expected_headers = ['OCLC Number', 'MMSID']
              expected_headers.each_with_index do |h, i_expected|
                i_actual = ss.find_column_index_by_header(h)
                expect(i_actual).to eq(i_expected)
              end
            end

            it 'returns nil for a nonexistent column' do
              c_index = ss.find_column_index_by_header('not a header')
              expect(c_index).to be_nil
            end
          end

          describe :find_column_index_by_header! do
            it 'finds the column index' do
              expected_headers = ['OCLC Number', 'MMSID']
              expected_headers.each_with_index do |h, i_expected|
                i_actual = ss.find_column_index_by_header!(h)
                expect(i_actual).to eq(i_expected)
              end
            end

            it 'raises ArgumentError for a nonexistent column' do
              expect { ss.find_column_index_by_header!('not a header') }.to raise_error(ArgumentError)
            end
          end

          describe :each_value do
            let(:expected_values) { ['OCLC Number', *oclc_numbers_expected.map(&:to_i)] }

            it 'returns an enumerator if no block given' do
              en = ss.each_value(0)
              expect(en).to be_a(Enumerator)

              expect(en.to_a).to eq(expected_values)
            end

            it 'yields the values' do
              expect { |b| ss.each_value(0, &b) }
                .to yield_successive_args(*expected_values)
            end

            it 'can skip the header' do
              expect { |b| ss.each_value(0, include_header: false, &b) }
                .to yield_successive_args(*expected_values[1..])
            end
          end

          describe :ensure_column! do
            it 'returns an existing column' do
              c_index = ss.ensure_column!('OCLC Number')
              expect(c_index).to eq(0)
            end

            it 'creates a new column' do
              new_header = 'New Header'
              c_index = ss.ensure_column!(new_header)
              expect(c_index).to eq(2)

              cell = ss.cell_at(0, c_index)
              expect(cell.value).to eq(new_header)
            end
          end

          describe :rows do

            it 'returns the rows' do
              rows = ss.rows
              expect(rows.size).to eq(ss.row_count)
              rows.each_with_index do |row, ri|
                expect(row).to be_a RubyXL::Row
                (0...row.size).each do |ci|
                  cell = row[ci]
                  v_actual = cell.value
                  v_expected = ss.value_at(ri, ci)
                  expect(v_actual).to eq(v_expected)
                end
              end
            end
          end

          describe :cell_at do
            it 'returns a cell' do
              expected_values = ['OCLC Number', *oclc_numbers_expected.map(&:to_i)]
              expected_values.each_with_index do |v_expected, ri|
                cell = ss.cell_at(ri, 0)
                v_actual = cell.value
                expect(v_actual).to eq(v_expected)
              end
            end

            it 'returns nil for a nonexistent row' do
              num_rows = ss.row_count
              cell = ss.cell_at(num_rows * 2, 1)
              expect(cell).to be_nil
            end

            it 'returns nil for a nonexistent column' do
              num_cols = ss.column_count
              cell = ss.cell_at(0, num_cols * 2)
              expect(cell).to be_nil
            end
          end

          describe :value_at do
            it 'returns a cell value' do
              expected_values = ['OCLC Number', *oclc_numbers_expected.map(&:to_i)]
              expected_values.each_with_index do |v_expected, ri|
                v_actual = ss.value_at(ri, 0)
                expect(v_actual).to eq(v_expected)
              end
            end

            it 'returns nil for a nonexistent row' do
              num_rows = ss.row_count
              cell = ss.value_at(num_rows * 2, 1)
              expect(cell).to be_nil
            end

            it 'returns nil for a nonexistent column' do
              num_cols = ss.column_count
              cell = ss.value_at(0, num_cols * 2)
              expect(cell).to be_nil
            end

            context 'with gaps' do
              let(:new_ri_max) { ss.row_count + 3 }
              let(:new_ci_max) { ss.column_count + 3 }

              def verify_value(ri, ci)
                row = ss.rows[ri]
                v_actual = ss.value_at(ri, ci)
                cell = (row[ci] if row)
                v_expected = cell ? cell.value : nil
                expect(v_expected).to eq(v_actual)
              end

              it 'returns nil for missing rows/columns' do
                ss.set_value_at(new_ri_max, new_ci_max, 'test')

                expected_row_count = 1 + new_ri_max
                expected_col_count = 1 + new_ci_max

                expect(ss.row_count).to eq(expected_row_count)
                expect(ss.column_count).to eq(expected_col_count)

                expect(ss.rows.size).to eq(expected_row_count)
                (0...expected_row_count).each do |ri|
                  row_col_count = ss.column_count(ri)
                  expect(row_col_count).to be <= expected_col_count

                  (0...expected_col_count).each do |ci|
                    verify_value(ri, ci)
                  end
                end
              end
            end
          end

          describe :set_value_at do
            it 'replaces an existing value' do
              r_index = 0
              c_index = 1
              old_value = 'MMSID'
              expect(ss.value_at(r_index, c_index)).to eq(old_value) # just to be sure
              new_value = 'MMS ID'
              ss.set_value_at(r_index, c_index, new_value)
              expect(ss.value_at(r_index, c_index)).to eq(new_value) # just to be sure
            end

            it 'writes to a new column' do
              r_index = 0
              c_index = 2
              expect(ss.value_at(r_index, c_index)).to be_nil # just to be sure
              new_value = 'Help I am trapped in a spreadsheet'
              ss.set_value_at(r_index, c_index, new_value)
              expect(ss.value_at(r_index, c_index)).to eq(new_value) # just to be sure
            end
          end

          describe :save_as do
            def assert_values_equal(ss_expected, ss_actual)
              num_rows = ss_expected.row_count
              expect(ss_actual.row_count).to eq(num_rows)

              (0...num_rows).each do |ri|
                num_cols = ss_expected.column_count(ri)
                expect(ss_actual.column_count(ri)).to eq(num_cols)

                (0...num_cols).each do |ci|
                  v_expected = ss_expected.value_at(ri, ci)
                  v_actual = ss_actual.value_at(ri, ci)
                  expect(v_actual).to eq(v_expected)
                end
              end
            end

            it 'saves the spreadsheet to a new path' do
              Dir.mktmpdir(File.basename(__FILE__)) do |dir|
                new_path = File.join(dir, 'test.xlsx')
                ss.save_as(new_path)
                expect(ss.xlsx_path).to eq(new_path)

                ss2 = Spreadsheet.new(new_path)
                assert_values_equal(ss, ss2)
              end
            end
          end
        end

        context 'without data' do
          let(:ss) { Spreadsheet.new('spec/data/excel/bad/oclc-numbers-empty.xlsx') }

          describe(:row_count) do
            it 'returns 0 for a spreadsheet with no rows' do
              expect(ss.row_count).to eq(0)
            end
          end

          describe(:column_count) do
            it 'returns 0 for a spreadsheet with no columns' do
              expect(ss.column_count).to eq(0)
            end
          end

          describe(:header_row) do
            it 'creates a header row if not present' do
              expect(ss.row_count).to eq(0) # just to be sure
              expect(ss.header_row).not_to be_nil
              expect(ss.row_count).to eq(1)
              expect(ss.column_count).to eq(0)
            end
          end
        end
      end
    end
  end
end
