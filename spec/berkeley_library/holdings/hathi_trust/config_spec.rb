require 'spec_helper'

module BerkeleyLibrary
  module Holdings
    module HathiTrust
      describe Config do
        after do
          Config.send(:reset!)
        end

        describe :hathitrust_base_uri do
          it 'defaults to the default URI' do
            expected_uri = URI.parse(Config::DEFAULT_HATHITRUST_BASE_URL)
            expect(Config.base_uri).to eq(expected_uri)
          end

          it 'can be set explictly as a URI' do
            expected_uri = URI.parse('https://catalog.hathitrust.test/api')

            Config.base_uri = expected_uri
            expect(Config.base_uri).to eq(expected_uri)
          end

          it 'can be set explictly as a string' do
            expected_url = 'https://catalog.hathitrust.test/api'
            expected_uri = URI.parse(expected_url)

            Config.base_uri = expected_url
            expect(Config.base_uri).to eq(expected_uri)
          end

          it 'reads from $LIT_HATHITRUST_BASE_URL' do
            expected_url = 'https://catalog.hathitrust.test/api'
            allow(ENV).to receive(:[]).with('LIT_HATHITRUST_BASE_URL').and_return(expected_url)

            expected_uri = URI.parse(expected_url)
            expect(Config.base_uri).to eq(expected_uri)
          end

          describe 'with Rails' do
            let(:rails_url) { 'https://catalog.hathitrust.test/api' }
            let(:rails_uri) { URI.parse(rails_url) }

            before do
              expect(defined?(Rails)).to be_nil # just to be sure

              rails = double(Object)
              Object.send(:const_set, 'Rails', rails)

              app = double(Object)
              allow(rails).to receive(:application).and_return(app)

              config = double(Object)
              allow(app).to receive(:config).and_return(config)

              allow(config).to receive(:hathitrust_base_url).and_return(rails_url)
            end

            after do
              Object.send(:remove_const, 'Rails')
            end

            it 'reads config.hathitrust_base_url' do
              expect(Config.base_uri).to eq(rails_uri)
            end

            it 'prefers $LIT_HATHITRUST_BASE_URL even when config.hathitrust_base_url is present' do
              expected_url = 'https://catalog.hathitrust.test/api/env'
              allow(ENV).to receive(:[]).with('LIT_HATHITRUST_BASE_URL').and_return(expected_url)

              expected_uri = URI.parse(expected_url)
              expect(Config.base_uri).to eq(expected_uri)
            end
          end
        end
      end
    end
  end
end
