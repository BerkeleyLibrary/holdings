require 'json'
require 'berkeley_library/util'
require 'berkeley_library/location/oclc_number'
require 'berkeley_library/location/hathi_trust/config'

module BerkeleyLibrary
  module Location
    module HathiTrust
      module RecordUrlRequestBase
        include BerkeleyLibrary::Util

        protected

        def volumes_base_uri
          URIs.append(Config.base_uri, 'volumes', 'brief')
        end

        def find_record_url(json_obj, oclc_number)
          return unless (records = json_obj['records'])
          return unless (record = find_record(records, oclc_number))

          record['recordURL']
        end

        def find_record(records, oclc_number)
          return if records.empty?

          records.values.find do |rec|
            (oclc_nums = rec['oclcs']) &&
              oclc_nums.include?(oclc_number) &&
              rec.key?('recordURL')
          end
        end
      end
    end
  end
end
