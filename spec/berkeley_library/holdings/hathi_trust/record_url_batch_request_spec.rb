require 'spec_helper'

module BerkeleyLibrary
  module Holdings
    module HathiTrust
      describe RecordUrlBatchRequest do
        let(:expected_urls) do
          {
            '1097551039' => 'https://catalog.hathitrust.org/Record/102799570',
            '1057635605' => 'https://catalog.hathitrust.org/Record/102799038',
            '744914764' => 'https://catalog.hathitrust.org/Record/102799171',
            '841051175' => 'https://catalog.hathitrust.org/Record/102798602',
            '553365107' => 'https://catalog.hathitrust.org/Record/009544358',
            '916723577' => 'https://catalog.hathitrust.org/Record/102797247',
            '50478533' => 'https://catalog.hathitrust.org/Record/004310786',
            '1037810804' => 'https://catalog.hathitrust.org/Record/102802328',
            '1106476939' => 'https://catalog.hathitrust.org/Record/102859665',
            '1019839414' => 'https://catalog.hathitrust.org/Record/102802377',
            '1202732743' => 'https://catalog.hathitrust.org/Record/102862428',
            '1232187285' => 'https://catalog.hathitrust.org/Record/102802512',
            '43310158' => 'https://catalog.hathitrust.org/Record/102822817',
            '786872103' => 'https://catalog.hathitrust.org/Record/102799040',
            '17401297' => 'https://catalog.hathitrust.org/Record/000883404',
            '39281966' => 'https://catalog.hathitrust.org/Record/003816675',
            '1088664799' => 'https://catalog.hathitrust.org/Record/102802305',
            '959808903' => 'https://catalog.hathitrust.org/Record/102798676',
            '1183717747' => 'https://catalog.hathitrust.org/Record/102862558',
            '840927703' => 'https://catalog.hathitrust.org/Record/102801650',
            '52559229' => 'https://catalog.hathitrust.org/Record/004355036',
            '1085156076' => 'https://catalog.hathitrust.org/Record/102802433',
            '1029560997' => 'https://catalog.hathitrust.org/Record/102797429',
            '942045029' => 'https://catalog.hathitrust.org/Record/102859735',
            '42780471' => 'https://catalog.hathitrust.org/Record/004134120',
            '1052450975' => 'https://catalog.hathitrust.org/Record/102805804',
            '992798630' => 'https://catalog.hathitrust.org/Record/102802179',
            '1243000176' => 'https://catalog.hathitrust.org/Record/102862468',
            '1003209782' => 'https://catalog.hathitrust.org/Record/102862406',
            '61332593' => 'https://catalog.hathitrust.org/Record/102799571',
            '34150960' => 'https://catalog.hathitrust.org/Record/003966672',
            '1081297655' => 'https://catalog.hathitrust.org/Record/102798906',
            '268789401' => 'https://catalog.hathitrust.org/Record/011248535',
            '1083300787' => 'https://catalog.hathitrust.org/Record/102798804',
            '895650546' => 'https://catalog.hathitrust.org/Record/102859604',
            '43903564' => 'https://catalog.hathitrust.org/Record/004136040',
            '52937386' => 'https://catalog.hathitrust.org/Record/004363197',
            '43845565' => 'https://catalog.hathitrust.org/Record/004135486',
            '169455558' => 'https://catalog.hathitrust.org/Record/005678848',
            '959373652' => 'https://catalog.hathitrust.org/Record/102797428',
            '916140635' => 'https://catalog.hathitrust.org/Record/102801980',
            '779577263' => 'https://catalog.hathitrust.org/Record/102801823',
            '41531832' => 'https://catalog.hathitrust.org/Record/004054696',
            '1233025104' => 'https://catalog.hathitrust.org/Record/102862415'
          }
        end
        let(:batches) { expected_urls.keys.each_slice(RecordUrlBatchRequest::MAX_BATCH_SIZE).to_a }

        describe :new do
          it 'allows retrieving a single record' do
            single_record_batch = batches[0][0...1]
            expect { RecordUrlBatchRequest.new(single_record_batch) }.not_to raise_error
          end

          it 'requires at least one OCLC number' do
            expect { RecordUrlBatchRequest.new([]) }.to raise_error(ArgumentError)
          end

          it 'rejects bad OCLC numbers' do
            batch = batches[0]
            aggregate_failures do
              [nil, '', batch[0].to_i, Object.new].each do |bad_oclc_number|
                bad_batch = [bad_oclc_number, *batch]
                expect { RecordUrlBatchRequest.new(bad_batch) }.to raise_error(ArgumentError)
              end
            end
          end
        end

        describe :uri do
          it 'returns the batch URI' do
            batch = batches[0]
            req = RecordUrlBatchRequest.new(batch)
            uri_actual = req.uri

            base_uri = Config.base_uri
            expect(uri_actual.scheme).to eq(base_uri.scheme)
            expect(uri_actual.host).to eq(base_uri.host)

            path_actual = uri_actual.path
            expect(path_actual).to start_with('/api/volumes/brief/')

            last_path_component = path_actual.split('/').last
            search_separator = Util::URIs.path_escape('|')
            searches = last_path_component.split(search_separator)
            batch.each do |expected_num|
              expect(searches).to include("oclc:#{expected_num}")
            end
          end
        end

        describe :execute do
          it 'retrieves record URLs' do
            batch = batches[0]
            req = RecordUrlBatchRequest.new(batch)
            batch_json = File.read('spec/data/hathi_trust/batch-0.json')
            stub_request(:get, req.uri).to_return(body: batch_json)

            record_urls = req.execute
            expect(record_urls.size).to eq(batch.size)
            batch.each do |oclc_num|
              url_expected = expected_urls[oclc_num]
              url_actual = record_urls[oclc_num]
              expect(url_actual).to eq(url_expected)
            end
          end

          it 'handles partial results' do
            expected_found = batches[0][0...10]
            expected_not_found = expected_found.map { |oclc_num| "9999#{oclc_num}" }
            batch = [*expected_found, *expected_not_found]
            req = RecordUrlBatchRequest.new(batch)
            batch_json = File.read('spec/data/hathi_trust/batch-partial.json')
            stub_request(:get, req.uri).to_return(body: batch_json)

            record_urls = req.execute
            expect(record_urls.size).to eq(expected_found.size)
            expected_found.each do |oclc_num|
              url_expected = expected_urls[oclc_num]
              url_actual = record_urls[oclc_num]
              expect(url_actual).to eq(url_expected)
            end

            expected_not_found.each do |oclc_num|
              expect(record_urls.key?(oclc_num)).to eq(false)
            end
          end

          # NOTE: HathiTrust *should* always return an entry for each OCLC number
          #       in the request, but just in case.
          it 'handles responses with the wrong OCLC numbers' do
            # should never happen according to Hathi docs, but just in case

            batch = batches[0].map(&:reverse)
            req = RecordUrlBatchRequest.new(batch)
            batch_json = File.read('spec/data/hathi_trust/batch-0.json')
            stub_request(:get, req.uri).to_return(body: batch_json)

            record_urls = req.execute
            expect(record_urls).to be_empty
          end
        end
      end
    end
  end
end
