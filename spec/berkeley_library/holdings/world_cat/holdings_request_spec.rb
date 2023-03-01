module BerkeleyLibrary
  module Holdings
    module WorldCat
      describe HoldingsRequest do
        let(:oclc_num) { '85833285' }

        describe :new do
          describe :oclc_number do
            it 'accepts a valid OCLC number' do
              q = HoldingsRequest.new(oclc_num)
              expect(q.oclc_number).to eq(oclc_num)
            end

            it 'rejects nil' do
              expect { HoldingsRequest.new(nil) }.to raise_error(ArgumentError)
            end

            it 'rejects the empty string' do
              expect { HoldingsRequest.new('') }.to raise_error(ArgumentError)
            end

            it 'rejects blank strings' do
              aggregate_failures do
                ["\t", ' ', "\r\n"].each do |bad_oclc_number|
                  expect { HoldingsRequest.new(bad_oclc_number) }.to raise_error(ArgumentError)
                end
              end
            end

            it 'rejects non-strings' do
              aggregate_failures do
                [Object.new, 85833285].each do |bad_oclc_number|
                  expect { HoldingsRequest.new(bad_oclc_number) }.to raise_error(ArgumentError)
                end
              end
            end
          end

          describe :symbols do
            it 'defaults to ALL' do
              q = HoldingsRequest.new(oclc_num)
              expect(q.symbols).to eq(Symbols::ALL)
            end

            it 'rejects an empty array' do
              expect { HoldingsRequest.new(oclc_num, symbols: []) }.to raise_error(ArgumentError)
            end

            it 'rejects a non-array' do
              expect { HoldingsRequest.new(oclc_num, symbols: Symbols::ALL.join(',')) }.to raise_error(ArgumentError)
            end

            it 'rejects an array containing nonexistent symbols' do
              bad_symbols = [Symbols::NRLF, ['not a WorldCat institution symbol'], Symbols::SRLF].flatten
              expect { HoldingsRequest.new(oclc_num, symbols: bad_symbols) }.to raise_error(ArgumentError)
            end
          end
        end
      end
    end
  end
end
