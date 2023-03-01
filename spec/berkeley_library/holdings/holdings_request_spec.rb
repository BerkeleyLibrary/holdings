require 'spec_helper'

module BerkeleyLibrary
  module Holdings
    describe HoldingsRequest do
      let(:oclc_number) { '10045193' }
      let(:wc_base_url) { 'https://www.example.test/webservices/' }
      let(:wc_api_key) { '2lo55pdh7moyfodeo4gwgms0on65x31ghv0g6yg87ffwaljsdw' }

      before do
        WorldCat::Config.base_uri = wc_base_url
        WorldCat::Config.api_key = wc_api_key
      end

      after do
        WorldCat::Config.send(:reset!)
      end

      describe :new do
        describe :oclc_number do
          it 'requires a valid OCLC number' do
            aggregate_failures do
              [nil, '', oclc_number.to_i, Object.new].each do |bad_oclc_number|
                expect { HoldingsRequest.new(bad_oclc_number) }.to raise_error(ArgumentError)
              end
            end
          end

          it 'accepts a valid OCLC number' do
            req = HoldingsRequest.new(oclc_number)
            expect(req.oclc_number).to eq(oclc_number)
          end
        end

        it 'must be for WorldCat institution symbols and/or HathiTrust record URL' do
          aggregate_failures do
            [nil, []].each do |no_symbols|
              expect { HoldingsRequest.new(oclc_number, wc_symbols: no_symbols, include_ht: false) }.to raise_error(ArgumentError)
            end
          end
        end

        it 'can be for just Hathi' do
          aggregate_failures do
            [nil, []].each do |no_symbols|
              req = HoldingsRequest.new(oclc_number, wc_symbols: no_symbols)
              expect(req.wc_symbols).to be_nil
              expect(req.include_ht?).to eq(true)
            end
          end
        end

        it 'can be for just institution symbols' do
          req = HoldingsRequest.new(oclc_number, include_ht: false)
          expect(req.wc_symbols).to eq(WorldCat::Symbols::ALL)
          expect(req.include_ht?).to eq(false)
        end
      end

      describe :execute do
        it 'retrieves WorldCat holdings' do
          holdings_xml = File.read('spec/data/worldcat/10045193-all.xml')
          holdings_expected = %w[CLU CUY]

          symbols = WorldCat::Symbols::ALL
          params = {
            oclcsymbol: symbols.join(','),
            servicelevel: 'full',
            frbrGrouping: 'off',
            wskey: wc_api_key
          }

          req = HoldingsRequest.new(oclc_number, include_ht: false)

          stub_request(:get, req.wc_uri)
            .with(query: params).to_return(body: holdings_xml)

          holdings_result = req.execute
          expect(holdings_result.wc_symbols).to contain_exactly(*holdings_expected)
        end

        it 'retrieves HathiTrust holdings' do
          records_json = File.read('spec/data/hathi_trust/10045193.json')
          url_expected = 'https://catalog.hathitrust.org/Record/102321413'

          req = HoldingsRequest.new(oclc_number, wc_symbols: [])
          stub_request(:get, req.ht_uri).to_return(body: records_json)

          holdings_result = req.execute
          expect(holdings_result.ht_record_url).to eq(url_expected)
        end

        it 'retrieves both' do
          holdings_xml = File.read('spec/data/worldcat/10045193-all.xml')
          holdings_expected = %w[CLU CUY]

          records_json = File.read('spec/data/hathi_trust/10045193.json')
          url_expected = 'https://catalog.hathitrust.org/Record/102321413'

          req = HoldingsRequest.new(oclc_number)

          symbols = WorldCat::Symbols::ALL
          params = {
            oclcsymbol: symbols.join(','),
            servicelevel: 'full',
            frbrGrouping: 'off',
            wskey: wc_api_key
          }

          stub_request(:get, req.wc_uri)
            .with(query: params).to_return(body: holdings_xml)

          stub_request(:get, req.ht_uri).to_return(body: records_json)

          holdings_result = req.execute
          expect(holdings_result.wc_symbols).to contain_exactly(*holdings_expected)
          expect(holdings_result.ht_record_url).to eq(url_expected)
        end

        it 'handles partial results' do
          holdings_xml = File.read('spec/data/worldcat/10045193-rlf.xml')

          records_json = File.read('spec/data/hathi_trust/10045193.json')
          url_expected = 'https://catalog.hathitrust.org/Record/102321413'

          symbols = WorldCat::Symbols::RLF
          req = HoldingsRequest.new(oclc_number, wc_symbols: symbols)

          params = {
            oclcsymbol: symbols.join(','),
            servicelevel: 'full',
            frbrGrouping: 'off',
            wskey: wc_api_key
          }

          stub_request(:get, req.wc_uri)
            .with(query: params).to_return(body: holdings_xml)

          stub_request(:get, req.ht_uri).to_return(body: records_json)

          holdings_result = req.execute
          expect(holdings_result.wc_symbols).to be_empty
          expect(holdings_result.ht_record_url).to eq(url_expected)
        end

        # rubocop:disable RSpec/ExampleLength
        describe 'error handling' do

          attr_reader :logger

          before do
            @logger = instance_double(BerkeleyLibrary::Logging::Logger)
            allow(BerkeleyLibrary::Logging).to receive(:logger).and_return(logger)
          end

          it 'returns Hathi results even in the event of a WorldCat error' do
            records_json = File.read('spec/data/hathi_trust/10045193.json')
            url_expected = 'https://catalog.hathitrust.org/Record/102321413'

            symbols = WorldCat::Symbols::RLF
            req = HoldingsRequest.new(oclc_number, wc_symbols: symbols)

            stub_request(:get, req.wc_uri)
              .with(query: hash_including({})).to_return(status: 503)

            stub_request(:get, req.ht_uri).to_return(body: records_json)

            expect(logger).to receive(:warn).with(
              a_string_including(oclc_number),
              instance_of(RestClient::ServiceUnavailable)
            )

            holdings_result = req.execute
            expect(holdings_result.wc_symbols).to be_empty
            expect(holdings_result.wc_error).to be_a(RestClient::ServiceUnavailable)
            expect(holdings_result.ht_record_url).to eq(url_expected)
            expect(holdings_result.ht_error).to be_nil
          end

          it 'returns WorldCat results even in the event of a Hathi error' do
            holdings_xml = File.read('spec/data/worldcat/10045193-all.xml')
            holdings_expected = %w[CLU CUY]

            req = HoldingsRequest.new(oclc_number)

            symbols = WorldCat::Symbols::ALL
            params = {
              oclcsymbol: symbols.join(','),
              servicelevel: 'full',
              frbrGrouping: 'off',
              wskey: wc_api_key
            }

            stub_request(:get, req.wc_uri)
              .with(query: params).to_return(body: holdings_xml)

            stub_request(:get, req.ht_uri).to_return(status: 503)

            expect(logger).to receive(:warn).with(
              a_string_including(oclc_number),
              instance_of(RestClient::ServiceUnavailable)
            )

            holdings_result = req.execute
            expect(holdings_result.wc_symbols).to contain_exactly(*holdings_expected)
            expect(holdings_result.wc_error).to be_nil
            expect(holdings_result.ht_record_url).to be_nil
            expect(holdings_result.ht_error).to be_a(RestClient::ServiceUnavailable)
          end

          it 'handles bad WorldCat data' do
            records_json = File.read('spec/data/hathi_trust/10045193.json')
            url_expected = 'https://catalog.hathitrust.org/Record/102321413'

            symbols = WorldCat::Symbols::RLF
            req = HoldingsRequest.new(oclc_number, wc_symbols: symbols)

            stub_request(:get, req.wc_uri)
              .with(query: hash_including({}))
              .to_return(body: '<?xml encoding="martian">')

            stub_request(:get, req.ht_uri).to_return(body: records_json)

            expect(logger).to receive(:warn).with(
              a_string_including(oclc_number),
              instance_of(Nokogiri::XML::SyntaxError)
            )

            holdings_result = req.execute
            expect(holdings_result.wc_symbols).to be_empty
            expect(holdings_result.wc_error).to be_a(Nokogiri::XML::SyntaxError)
            expect(holdings_result.ht_record_url).to eq(url_expected)
            expect(holdings_result.ht_error).to be_nil
          end

          it 'handles bad HathiTrust data' do
            holdings_xml = File.read('spec/data/worldcat/10045193-all.xml')
            holdings_expected = %w[CLU CUY]

            req = HoldingsRequest.new(oclc_number)

            symbols = WorldCat::Symbols::ALL
            params = {
              oclcsymbol: symbols.join(','),
              servicelevel: 'full',
              frbrGrouping: 'off',
              wskey: wc_api_key
            }

            stub_request(:get, req.wc_uri)
              .with(query: params).to_return(body: holdings_xml)

            stub_request(:get, req.ht_uri).to_return(body: 'I am not a JSON object')

            expect(logger).to receive(:warn).with(
              a_string_including(oclc_number),
              instance_of(JSON::ParserError)
            )

            holdings_result = req.execute
            expect(holdings_result.wc_symbols).to contain_exactly(*holdings_expected)
            expect(holdings_result.wc_error).to be_nil
            expect(holdings_result.ht_record_url).to be_nil
            expect(holdings_result.ht_error).to be_a(JSON::ParserError)
          end

        end
        # rubocop:enable RSpec/ExampleLength
      end
    end
  end
end
