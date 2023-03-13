require 'spec_helper'

module BerkeleyLibrary
  module Holdings
    describe XLSXReader do
      describe :new do
        context 'invalid formats' do

          it 'rejects an Excel 95 (.xls) workbook' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-excel95.xls'

            expect { XLSXReader.new(xls_path) }.to raise_error(ArgumentError)
          end

          it 'rejects an Excel 97 (.xls) workbook' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-excel97.xls'

            expect { XLSXReader.new(xls_path) }.to raise_error(ArgumentError)
          end

          it 'rejects an Excel 95 workbook renamed to .xlsx' do
            xls_path = 'spec/data/excel/bad/oclc-numbers-excel95-as-xlsx.xlsx'

            expect { XLSXReader.new(xls_path) }.to raise_error(ArgumentError)
          end
        end

        context 'invalid contents' do
          it 'rejects an empty spreadsheet' do
            xlsx_path = 'spec/data/excel/bad/oclc-numbers-empty.xlsx'

            expect { XLSXReader.new(xlsx_path) }.to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet with blank headers' do
            xlsx_path = 'spec/data/excel/bad/oclc-numbers-blank-header.xlsx'

            expect { XLSXReader.new(xlsx_path) }.to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet with empty headers' do
            xlsx_path = 'spec/data/excel/bad/oclc-numbers-empty-header.xlsx'

            expect { XLSXReader.new(xlsx_path) }.to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet without headers' do
            xlsx_path = 'spec/data/excel/bad/oclc-numbers-missing-header.xlsx'

            expect { XLSXReader.new(xlsx_path) }.to raise_error(ArgumentError)
          end

          it 'rejects a spreadsheet without an OCLC Numbers column' do
            xlsx_path = 'spec/data/excel/bad/oclc-numbers-no-oclc-col.xlsx'

            expect { XLSXReader.new(xlsx_path) }.to raise_error(ArgumentError)
          end
        end
      end

      describe :each_oclc_number do
        let(:oclc_numbers_expected) { File.readlines('spec/data/excel/oclc_numbers_expected.txt', chomp: true) }

        it 'returns an enumerator if no block given' do
          xlsx_path = 'spec/data/excel/oclc-numbers.xlsx'
          en = XLSXReader.new(xlsx_path).each_oclc_number
          expect(en).to be_a(Enumerator)
          expect(en.to_a).to eq(oclc_numbers_expected)
        end

        it 'finds OCLC numbers as numbers' do
          reader = XLSXReader.new('spec/data/excel/oclc-numbers.xlsx')
          expect { |b| reader.each_oclc_number(&b) }
            .to yield_successive_args(*oclc_numbers_expected)
        end

        it 'finds OCLC numbers as strings' do
          reader = XLSXReader.new('spec/data/excel/oclc-numbers-text.xlsx')
          expect { |b| reader.each_oclc_number(&b) }
            .to yield_successive_args(*oclc_numbers_expected)
        end

        it 'skips blank cells' do
          reader = XLSXReader.new('spec/data/excel/oclc-numbers-sparse.xlsx')
          expect { |b| reader.each_oclc_number(&b) }
            .to yield_successive_args(*oclc_numbers_expected)
        end

        it 'finds OCLC numbers in later columns' do
          reader = XLSXReader.new('spec/data/excel/oclc-numbers-extra-cols.xlsx')
          expect { |b| reader.each_oclc_number(&b) }
            .to yield_successive_args(*oclc_numbers_expected)
        end
      end

    end
  end
end
