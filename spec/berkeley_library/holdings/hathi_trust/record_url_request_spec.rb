require 'spec_helper'

module BerkeleyLibrary
  module Holdings
    module HathiTrust
      describe RecordUrlRequest do
        let(:ht_base_url) { 'https://catalog.example.test/api/' }
        let(:oclc_number) { '10045193' }

        before do
          Config.base_uri = ht_base_url
        end

        after do
          Config.send(:reset!)
        end

        describe :uri do
          it 'returns the URI for the specified OCLC number' do
            uri_expected = URI.parse("#{ht_base_url}volumes/brief/oclc/#{oclc_number}.json")
            uri_actual = RecordUrlRequest.new(oclc_number).uri
            expect(uri_actual).to eq(uri_expected)
          end

          it 'handles bad OCLC numbers' do
            oclc_number = 'I am not an OCLC number'
            oclc_number_escaped = BerkeleyLibrary::Util::URIs.path_escape(oclc_number)
            uri_expected = URI.parse("#{ht_base_url}volumes/brief/oclc/#{oclc_number_escaped}.json")
            uri_actual = RecordUrlRequest.new(oclc_number).uri
            expect(uri_actual).to eq(uri_expected)
          end
        end

        describe :execute do
          it 'returns the record URL for the specified OCLC number' do
            records_json = File.read('spec/data/hathi_trust/10045193.json')
            url_expected = 'https://catalog.hathitrust.org/Record/102321413'

            req = RecordUrlRequest.new(oclc_number)
            stub_request(:get, req.uri).to_return(body: records_json)

            url_actual = req.execute
            expect(url_actual).to eq(url_expected)
          end

          it 'returns nil for an item not in HathiTrust' do
            oclc_number = '1152527909'
            records_json = File.read('spec/data/hathi_trust/1152527909.json')

            req = RecordUrlRequest.new(oclc_number)
            stub_request(:get, req.uri).to_return(body: records_json)

            url_actual = req.execute
            expect(url_actual).to be_nil
          end

          it 'returns nil for an empty JSON response' do
            oclc_number = '1152527909'
            records_json = '{}'

            req = RecordUrlRequest.new(oclc_number)
            stub_request(:get, req.uri).to_return(body: records_json)

            url_actual = req.execute
            expect(url_actual).to be_nil
          end

          # NOTE: HathiTrust *should* only return record URLs for items
          #       with the specified OCLC number, but we filter just in case.
          it 'returns nil when Hathi returns the wrong object' do
            oclc_number = '1152527909'
            records_json = File.read('spec/data/hathi_trust/10045193.json')

            req = RecordUrlRequest.new(oclc_number)
            stub_request(:get, req.uri)
              .to_return(body: records_json)

            url_actual = req.execute
            expect(url_actual).to be_nil
          end
        end
      end
    end
  end
end
