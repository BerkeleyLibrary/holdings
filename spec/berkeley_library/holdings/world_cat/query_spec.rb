require 'spec_helper'

module BerkeleyLibrary
  module Holdings
    module WorldCat
      describe Query do
        let(:oclc_num) { '85833285' }

        describe :new do
          describe :oclc_number do
            it 'rejects nil' do
              expect { Query.new(nil) }.to raise_error(ArgumentError)
            end

            it 'rejects the empty string' do
              expect { Query.new('') }.to raise_error(ArgumentError)
            end

            it 'rejects blank strings' do
              aggregate_failures do
                ["\t", ' ', "\r\n"].each do |bad_oclc_number|
                  expect { Query.new(bad_oclc_number) }.to raise_error(ArgumentError)
                end
              end
            end

            it 'rejects non-strings' do
              aggregate_failures do
                [Object.new, 85833285].each do |bad_oclc_number|
                  expect { Query.new(bad_oclc_number) }.to raise_error(ArgumentError)
                end
              end
            end
          end

          describe :symbols do
            it 'defaults to ALL' do
              q = Query.new(oclc_num)
              expect(q.symbols).to eq(Symbols::ALL)
            end

            it 'rejects an empty array' do
              expect { Query.new(oclc_num, []) }.to raise_error(ArgumentError)
            end

            it 'rejects a non-array' do
              expect { Query.new(oclc_num, Symbols::ALL.join(',')) }.to raise_error(ArgumentError)
            end

            it 'rejects an array containing nonexistent symbols' do
              bad_symbols = [Symbols::NRLF, ['not a WorldCat institution symbol'], Symbols::SRLF].flatten
              expect { Query.new(oclc_num, bad_symbols) }.to raise_error(ArgumentError)
            end
          end
        end
      end
    end
  end
end
