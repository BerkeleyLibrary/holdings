require 'json'
require 'berkeley_library/util'
require 'berkeley_library/holdings/oclc_number'
require 'berkeley_library/holdings/hathi_trust/config'

module BerkeleyLibrary
  module Holdings
    module HathiTrust
      class RecordUrlBatchRequest
        include BerkeleyLibrary::Util

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
          @uri ||= URIs.append(volumes_base_uri, 'json', oclc_list)
        end

        private

        def ensure_valid_oclc_numbers!(oclc_numbers)
          raise ArgumentError, 'No OCLC numbers provided' if oclc_numbers.empty?
          raise ArgumentError, "Too many OCLC numbers; expected <= #{MAX_BATCH_SIZE}, was #{oclc_numbers.size}" if oclc_numbers.size > MAX_BATCH_SIZE

          OCLCNumber.ensure_oclc_numbers!(oclc_numbers)
        end

        # TODO: share code w/RecordUrlBatchRequest
        def volumes_base_uri
          URIs.append(Config.base_uri, 'volumes', 'brief')
        end

        def oclc_list
          @oclc_list = oclc_numbers.map { |oclc_number| "oclc:#{oclc_number}" }.join(';')
        end

        def record_urls_from(json_str)
          all_record_urls = all_record_urls_from(json_str)
          oclc_numbers.filter_map do |oclc_num|
            next unless (record_url = all_record_urls[oclc_num])

            [oclc_num, record_url]
          end.to_h
        end

        def all_record_urls_from(json_str)
          json = JSON.parse(json_str)

          {}.tap do |urls|
            next unless (records = json['records'])

            records.each_value do |rec|
              rec['oclcs'].each do |oclc_num|
                urls[oclc_num] = record['recordURL']
              end
            end
          end
        end

        # def record_url_from(json_str, oclc_number)
        #   json = JSON.parse(json_str)
        #   return unless (records = json['records'])
        #   return unless (record = find_record(records, oclc_number))
        #
        #   record['recordURL']
        # end
        #
        # def find_record(records, oclc_number)
        #   records.values.find do |rec|
        #     (oclc_nums = rec['oclcs']) && oclc_nums.include?(oclc_number)
        #   end
        # end

      end
    end
  end
end
