require 'json'
require 'rest-client'
require 'berkeley_library/holdings/oclc_number'
require 'berkeley_library/holdings/hathi_trust/config'

module BerkeleyLibrary
  module Holdings
    module HathiTrust
      class RecordUrlRequest
        include BerkeleyLibrary::Util
        include BerkeleyLibrary::Logging

        attr_reader :oclc_number

        def initialize(oclc_number)
          @oclc_number = OCLCNumber.ensure_oclc_number!(oclc_number)
        end

        def execute
          response = RestClient.get(uri.to_s)
          record_url_from(response.body, oclc_number)
        rescue StandardError => e
          logger.warn("Error HathiTrust record URL for #{oclc_number.inspect}", e)

          nil
        end

        def uri
          @uri ||= URIs.append(volumes_base_uri, "#{oclc_number}.json")
        end

        private

        def volumes_base_uri
          URIs.append(Config.base_uri, 'volumes', 'brief', 'oclc')
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
