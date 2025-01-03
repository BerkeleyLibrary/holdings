module BerkeleyLibrary
  module Location
    module WorldCat
      describe LibrariesRequest do
        let(:oclc_number) { '85833285' }
        # let(:wc_base_url) { 'https://www.example.test/webservices/' }
        let(:wc_base_url) { 'https://americas.discovery.api.oclc.org/worldcat/search/v2/' }
        let(:wc_api_key) { '2lo55pdh7moyfodeo4gwgms0on65x31ghv0g6yg87ffwaljsdw' }
        let(:wc_api_secret) { 'totallyfakesecret' }

        # before do
        #   # Config.base_uri = wc_base_url
        #   # Config.api_key = wc_api_key
        #   # Config.api_secret = wc_api_secret
        # end

        after do
          Config.send(:reset!)
        end

        describe :new do
          describe :oclc_number do
            it 'accepts a valid OCLC number' do
              q = LibrariesRequest.new(oclc_number)
              expect(q.oclc_number).to eq(oclc_number)
            end

            it 'rejects nil' do
              expect { LibrariesRequest.new(nil) }.to raise_error(ArgumentError)
            end

            it 'rejects the empty string' do
              expect { LibrariesRequest.new('') }.to raise_error(ArgumentError)
            end

            it 'rejects blank strings' do
              aggregate_failures do
                ["\t", ' ', "\r\n"].each do |bad_oclc_number|
                  expect { LibrariesRequest.new(bad_oclc_number) }.to raise_error(ArgumentError)
                end
              end
            end

            it 'rejects non-strings' do
              aggregate_failures do
                [Object.new, 85833285].each do |bad_oclc_number|
                  expect { LibrariesRequest.new(bad_oclc_number) }.to raise_error(ArgumentError)
                end
              end
            end
          end

          describe :symbols do
            it 'defaults to ALL' do
              q = LibrariesRequest.new(oclc_number)
              expect(q.symbols).to eq(Symbols::ALL)
            end

            it 'rejects an empty array' do
              expect { LibrariesRequest.new(oclc_number, symbols: []) }.to raise_error(ArgumentError)
            end

            it 'rejects a non-array' do
              expect { LibrariesRequest.new(oclc_number, symbols: Symbols::ALL.join(',')) }.to raise_error(ArgumentError)
            end

            it 'rejects an array containing nonexistent symbols' do
              bad_symbols = [Symbols::NRLF, ['not a WorldCat institution symbol'], Symbols::SRLF].flatten
              expect { LibrariesRequest.new(oclc_number, symbols: bad_symbols) }.to raise_error(ArgumentError)
            end
          end
        end

        # How to handle these tests... now the oclc number is passed as a parameter
        # and NOT in the URI...so these are kind of moot.
        describe :uri do
          it 'returns the URI for the specified OCLC number' do
            uri_expected = URI.parse("#{wc_base_url}bibs-holdings")
            uri_actual = LibrariesRequest.new(oclc_number).uri
            expect(uri_actual).to eq(uri_expected)
          end
        end

        describe :execute do
          it 'returns the holdings' do
            holdings_xml = File.read('spec/data/worldcat/85833285-all.xml')
            holdings_expected = %w[CUI CUY MERUC ZAP]

            symbols = Symbols::ALL
            params = {
              'oclcNumber' => oclc_number,
              'heldBySymbol' => symbols.join(',')
            }

            req = LibrariesRequest.new(oclc_number)

            VCR.use_cassette('libraries_request/execute_holdings_1') do
              holdings_actual = req.execute
              expect(holdings_actual).to contain_exactly(*holdings_expected)
            end
          end

          it 'returns a specified subset of holdings' do
            holdings_xml = File.read('spec/data/worldcat/85833285-rlf.xml')
            holdings_expected = %w[ZAP]

            symbols = Symbols::RLF
            params = {
              'oclcNumber' => oclc_number,
              'heldBySymbol' => symbols.join(',')
            }

            req = LibrariesRequest.new(oclc_number, symbols:)

            VCR.use_cassette('libraries_request/execute_holdings_2') do
              holdings_actual = req.execute
              expect(holdings_actual).to contain_exactly(*holdings_expected)
            end
          end

          # NOTE: WorldCat *shouldn't* return holdings information for any
          #       but the requested symbols, but we filter just in case.
          it "returns only the requested symbols, even if OCLC doesn't" do
            holdings_xml = File.read('spec/data/worldcat/85833285-all.xml')
            holdings_expected = %w[CUI CUY MERUC]

            symbols = Symbols::UC
            params = {
              'oclcNumber' => oclc_number,
              'heldBySymbol' => symbols.join(',')
            }

            req = LibrariesRequest.new(oclc_number, symbols:)

            VCR.use_cassette('libraries_request/execute_holdings_3') do
              holdings_actual = req.execute
              expect(holdings_actual).to contain_exactly(*holdings_expected)
            end
          end

          it 'returns an empty list when no holdings are found' do
            oclc_number = '10045193'
            holdings_xml = File.read('spec/data/worldcat/10045193-rlf.xml')

            symbols = Symbols::RLF
            params = {
              'oclcNumber' => oclc_number,
              'heldBySymbol' => symbols.join(',')
            }

            req = LibrariesRequest.new(oclc_number, symbols:)

            VCR.use_cassette('libraries_request/execute_holdings_4') do
              holdings_actual = req.execute
              expect(holdings_actual).to be_empty
            end
          end
        end
      end
    end
  end
end
