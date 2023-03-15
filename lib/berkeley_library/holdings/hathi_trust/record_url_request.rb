require 'json'
require 'berkeley_library/util'
require 'berkeley_library/holdings/oclc_number'
require 'berkeley_library/holdings/hathi_trust/config'

module BerkeleyLibrary
  module Holdings
    module HathiTrust
      class RecordUrlRequest
        include BerkeleyLibrary::Util

        attr_reader :oclc_number

        def initialize(oclc_number)
          @oclc_number = OCLCNumber.ensure_oclc_number!(oclc_number)
        end

        def execute
          response_body = URIs.get(uri, log: false)
          record_url_from(response_body, oclc_number)
        end

        def uri
          @uri ||= URIs.append(volumes_base_uri, 'oclc', "#{oclc_number}.json")
        end

        private

        # TODO: share code w/RecordUrlBatchRequest
        def volumes_base_uri
          URIs.append(Config.base_uri, 'volumes', 'brief')
        end

        def record_url_from(json_str, oclc_number)
          json = JSON.parse(json_str)
          return unless (records = json['records'])
          return unless (record = find_record(records, oclc_number))

          record['recordURL']
        end

        def find_record(records, oclc_number)
          records.values.find do |rec|
            (oclc_nums = rec['oclcs']) && oclc_nums.include?(oclc_number)
          end
        end

      end
    end
  end
end
