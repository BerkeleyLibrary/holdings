require 'berkeley_library/holdings/hathi_trust/record_url_request_base'

module BerkeleyLibrary
  module Holdings
    module HathiTrust
      class RecordUrlBatchRequest
        include RecordUrlRequestBase

        # Per HathiTrust API docs: https://www.hathitrust.org/bib_api
        MAX_BATCH_SIZE = 20

        attr_reader :oclc_numbers

        def initialize(oclc_numbers)
          @oclc_numbers = ensure_valid_oclc_numbers!(oclc_numbers)
        end

        def execute
          response_body = URIs.get(uri, log: false)
          record_urls_from(response_body)
        end

        def uri
          @uri ||= URIs.append(volumes_base_uri, 'json', URIs.path_escape(oclc_list))
        end

        private

        def ensure_valid_oclc_numbers!(oclc_numbers)
          raise ArgumentError, 'No OCLC numbers provided' if oclc_numbers.empty?
          raise ArgumentError, "Too many OCLC numbers; expected <= #{MAX_BATCH_SIZE}, was #{oclc_numbers.size}" if oclc_numbers.size > MAX_BATCH_SIZE

          OCLCNumber.ensure_oclc_numbers!(oclc_numbers)
        end

        def oclc_list
          @oclc_list = oclc_numbers.map(&method(:key_for)).join('|')
        end

        def key_for(oclc_number)
          "oclc:#{oclc_number}"
        end

        def record_urls_from(json_str)
          json = JSON.parse(json_str)
          oclc_numbers.filter_map do |oclc_num|
            next unless (entry = json[key_for(oclc_num)])

            record_url = find_record_url(entry, oclc_num)
            [oclc_num, record_url] if record_url
          end.to_h
        end
      end
    end
  end
end
