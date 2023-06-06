require 'berkeley_library/location/hathi_trust/record_url_request_base'

module BerkeleyLibrary
  module Location
    module HathiTrust
      class RecordUrlRequest
        include RecordUrlRequestBase

        attr_reader :oclc_number

        def initialize(oclc_number)
          @oclc_number = OCLCNumber.ensure_oclc_number!(oclc_number)
        end

        def execute
          response_body = URIs.get(uri, log: false)
          record_url_from(response_body, oclc_number)
        end

        def uri
          @uri ||= URIs.append(volumes_base_uri, 'oclc', URIs.path_escape("#{oclc_number}.json"))
        end

        private

        def record_url_from(json_str, oclc_number)
          json_obj = JSON.parse(json_str)
          find_record_url(json_obj, oclc_number)
        end
      end
    end
  end
end
