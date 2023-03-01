require 'spec_helper'

module BerkeleyLibrary
  module Holdings
    module WorldCat
      describe Config do
        after do
          Config.send(:reset!)
        end

        describe :api_key do
          it 'defaults to nil' do
            expect(Config.api_key).to be_nil
          end

          it 'can be set explicitly' do
            expected_key = 'halp I am trapped in a unit test'
            Config.api_key = expected_key
            expect(Config.api_key).to eq(expected_key)
          end

          it 'reads from $LIT_WORLDCAT_API_KEY' do
            expected_key = '2lo55pdh7moyfodeo4gwgms0on65x31ghv0g6yg87ffwaljsdw'
            allow(ENV).to receive(:[]).with('LIT_WORLDCAT_API_KEY').and_return(expected_key)

            expect(Config.api_key).to eq(expected_key)
          end

          describe 'with Rails' do
            let(:rails_key) { '2lo55pdh7moyfodeo4gwgms0on65x31ghv0g6yg87ffwaljsdw' }

            before do
              expect(defined?(Rails)).to be_nil # just to be sure

              rails = double(Object)
              Object.send(:const_set, 'Rails', rails)

              app = double(Object)
              allow(rails).to receive(:application).and_return(app)

              config = double(Object)
              allow(app).to receive(:config).and_return(config)

              allow(config).to receive(:worldcat_api_key).and_return(rails_key)
            end

            after do
              Object.send(:remove_const, 'Rails')
            end

            it 'reads config.worldcat_api_key' do
              expect(Config.api_key).to eq(rails_key)
            end

            it 'prefers $LIT_WORLDCAT_API_KEY even when config.worldcat_api_key is present' do
              expected_key = '2lo55pdh7moyfodeo4gwgms0on65x31ghv0g6yg87ffwaljsdw'.reverse
              allow(ENV).to receive(:[]).with('LIT_WORLDCAT_API_KEY').and_return(expected_key)
              expect(Config.api_key).to eq(expected_key)
            end
          end
        end

        describe :worldcat_base_uri do
          it 'defaults to the default URI' do
            expected_uri = URI.parse(Config::DEFAULT_WORLDCAT_BASE_URL)
            expect(Config.base_uri).to eq(expected_uri)
          end

          it 'can be set explictly as a URI' do
            expected_uri = URI.parse('https://www.worldcat.test/webservices/')

            Config.base_uri = expected_uri
            expect(Config.base_uri).to eq(expected_uri)
          end

          it 'can be set explictly as a string' do
            expected_url = 'https://www.worldcat.test/webservices/'
            expected_uri = URI.parse(expected_url)

            Config.base_uri = expected_url
            expect(Config.base_uri).to eq(expected_uri)
          end

          it 'reads from $LIT_WORLDCAT_BASE_URL' do
            expected_url = 'https://www.worldcat.test/webservices'
            allow(ENV).to receive(:[]).with('LIT_WORLDCAT_BASE_URL').and_return(expected_url)

            expected_uri = URI.parse(expected_url)
            expect(Config.base_uri).to eq(expected_uri)
          end

          describe 'with Rails' do
            let(:rails_url) { 'https://www.worldcat.test/webservices' }
            let(:rails_uri) { URI.parse(rails_url) }

            before do
              expect(defined?(Rails)).to be_nil # just to be sure

              rails = double(Object)
              Object.send(:const_set, 'Rails', rails)

              app = double(Object)
              allow(rails).to receive(:application).and_return(app)

              config = double(Object)
              allow(app).to receive(:config).and_return(config)

              allow(config).to receive(:worldcat_base_url).and_return(rails_url)
            end

            after do
              Object.send(:remove_const, 'Rails')
            end

            it 'reads config.worldcat_base_url' do
              expect(Config.base_uri).to eq(rails_uri)
            end

            it 'prefers $LIT_WORLDCAT_BASE_URL even when config.worldcat_base_url is present' do
              expected_url = 'https://www.worldcat.test/webservices'
              allow(ENV).to receive(:[]).with('LIT_WORLDCAT_BASE_URL').and_return(expected_url)

              expected_uri = URI.parse(expected_url)
              expect(Config.base_uri).to eq(expected_uri)
            end
          end
        end
      end
    end
  end
end
