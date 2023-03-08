require 'spec_helper'

module BerkeleyLibrary
  module Holdings
    describe Spreadsheets do
      describe :oclc_numbers_from do
        let(:oclc_numbers_expected) { File.readlines('spec/data/excel/oclc_numbers_expected.txt', chomp: true) }

        it 'returns an enumerator if no block given' do
          xlsx_path = 'spec/data/excel/oclc-numbers.xlsx'
          en = Spreadsheets.oclc_numbers_from(xlsx_path)
          expect(en).to be_a(Enumerator)
          expect(en.to_a).to eq(oclc_numbers_expected)
        end

        context 'success' do
          it 'finds OCLC numbers as numbers' do
            xlsx_path = 'spec/data/excel/oclc-numbers.xlsx'
            expect { |b| Spreadsheets.oclc_numbers_from(xlsx_path, &b) }
              .to yield_successive_args(*oclc_numbers_expected)
          end

          it 'finds OCLC numbers as strings' do
            xlsx_path = 'spec/data/excel/oclc-numbers-text.xlsx'
            expect { |b| Spreadsheets.oclc_numbers_from(xlsx_path, &b) }
              .to yield_successive_args(*oclc_numbers_expected)
          end

          it 'skips blank cells' do
            xlsx_path = 'spec/data/excel/oclc-numbers-sparse.xlsx'
            expect { |b| Spreadsheets.oclc_numbers_from(xlsx_path, &b) }
              .to yield_successive_args(*oclc_numbers_expected)
          end

          it 'finds OCLC numbers in later columns' do
            xlsx_path = 'spec/data/excel/oclc-numbers-extra-cols.xlsx'
            expect { |b| Spreadsheets.oclc_numbers_from(xlsx_path, &b) }
              .to yield_successive_args(*oclc_numbers_expected)
          end
        end

        context 'failure' do
          it 'rejects an Excel 95 (.xls) workbook' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-excel95.xls'

            expect { Spreadsheets.oclc_numbers_from(xls_path).to_a }
              .to raise_error(ArgumentError)
          end

          it 'rejects an Excel 97 (.xls) workbook' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-excel97.xls'

            expect { Spreadsheets.oclc_numbers_from(xls_path).to_a }
              .to raise_error(ArgumentError)
          end

          it 'rejects an Excel 95 workbook renamed to .xlsx' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-excel95-as-xlsx.xlsx'

            expect { Spreadsheets.oclc_numbers_from(xls_path).to_a }
              .to raise_error(ArgumentError)
          end

          it 'rejects an empty spreadsheet' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-empty.xlsx'

            expect { Spreadsheets.oclc_numbers_from(xls_path).to_a }
              .to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet with blank headers' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-blank-header.xlsx'

            expect { Spreadsheets.oclc_numbers_from(xls_path).to_a }
              .to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet with empty headers' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-empty-header.xlsx'

            expect { Spreadsheets.oclc_numbers_from(xls_path).to_a }
              .to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet without headers' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-missing-header.xlsx'

            expect { Spreadsheets.oclc_numbers_from(xls_path).to_a }
              .to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet without an OCLC Numbers column' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-no-oclc-col.xlsx'

            expect { Spreadsheets.oclc_numbers_from(xls_path).to_a }
              .to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
