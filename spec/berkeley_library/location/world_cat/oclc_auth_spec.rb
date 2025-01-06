require 'spec_helper'

module BerkeleyLibrary
  module Location
    module WorldCat
      describe OCLCAuth do
        it 'fetches a token' do
          VCR.use_cassette('oclc_auth/fetch_token') do
            token = OCLCAuth.instance.token
            expect(token).to be_a(Hash)
            expect(token[:access_token]).to be_a(String)
          end
        end

        it 'refreshes a token' do
          VCR.use_cassette('oclc_auth/refresh_token') do
            token = OCLCAuth.instance.token

            # Need to set the token expiration to a time in the past
            token[:expires_at] = (Time.now - 1).to_s
            OCLCAuth.instance.token = token
            access_token = OCLCAuth.instance.access_token

            expect(OCLCAuth.instance.token[:access_token]).to be_a(String)
          end
        end
      end
    end
  end
end