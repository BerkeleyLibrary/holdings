require 'spec_helper'

module BerkeleyLibrary
  module Location
    module WorldCat
      describe Config do
        after do
          Config.send(:reset!)
        end

        describe 'Rails Fallbacks' do
          around do |example|
            preserved_key = ENV['LIT_WORLDCAT_API_KEY']
            preserved_secret = ENV['LIT_WORLDCAT_API_SECRET']
            preserved_base = ENV['LIT_WORLDCAT_BASE_URL']

            ENV['LIT_WORLDCAT_API_KEY'] = nil
            ENV['LIT_WORLDCAT_API_SECRET'] = nil
            ENV['LIT_WORLDCAT_BASE_URL'] = nil

            expect(defined?(Rails)).to be_nil # just to be sure

            rails = double(Object)
            Object.send(:const_set, 'Rails', rails)

            # Reset Config memoization before running the example
            Config.instance_variable_set(:@api_key, nil)
            Config.instance_variable_set(:@api_secret, nil)
            Config.instance_variable_set(:@base_uri, nil)

            example.run

            Object.send(:remove_const, 'Rails')
            ENV['LIT_WORLDCAT_API_KEY'] = preserved_key
            ENV['LIT_WORLDCAT_API_SECRET'] = preserved_secret
            ENV['LIT_WORLDCAT_BASE_URL'] = preserved_base
          end

          it 'reads API key from Rails' do
            expected_key = '2lo55pdh7moyfodeo4gwgms0on65x31ghv0g6yg87ffwaljsdw'

            app = double(Object)
            allow(Rails).to receive(:application).and_return(app)

            config = double(Object)
            allow(app).to receive(:config).and_return(config)

            allow(config).to receive(:worldcat_api_key).and_return(expected_key)

            expect(Config.api_key).to eq(expected_key)
          end

          it 'reads API secret from Rails' do
            expected_secret = 'totally_fake_secret'

            app = double(Object)
            allow(Rails).to receive(:application).and_return(app)

            config = double(Object)
            allow(app).to receive(:config).and_return(config)

            allow(config).to receive(:worldcat_api_secret).and_return(expected_secret)

            expect(Config.api_secret).to eq(expected_secret)
          end

          it 'reads base URI from Rails' do
            expected_value = 'totally_fake_uri'

            app = double(Object)
            allow(Rails).to receive(:application).and_return(app)

            config = double(Object)
            allow(app).to receive(:config).and_return(config)

            allow(config).to receive(:worldcat_base_url).and_return(expected_value)

            expect(Config.base_uri.to_s).to eq(expected_value)
          end

          # it 'reads oclc token url from Rails' do
          #   expected_value = 'totally_fake_uri'

          #   app = double(Object)
          #   allow(Rails).to receive(:application).and_return(app)

          #   config = double(Object)
          #   allow(app).to receive(:config).and_return(config)

          #   allow(config).to receive(:oclc_token_url).and_return(expected_value)

          #   expect(Config.token_uri.to_s).to eq(expected_value)
          # end

        end

        describe :base_uri do
          it 'is not nil' do
            expect(Config.base_uri).not_to be_nil
          end

          it 'base can be set explicity' do
            expected_uri = 'https://www.example.test/webservices/'
            Config.base_uri = expected_uri

            expect(Config.base_uri.to_s).to eq(expected_uri)
          end
        end

        describe :token_uri do
          it 'is not nil' do
            expect(Config.token_uri).not_to be_nil
          end

          it 'can be set explicitly' do
            preserved_uri = Config.token_uri

            expected_uri = 'https://fake.token.uri'
            Config.token_uri = expected_uri

            expect(Config.token_uri.to_s).to eq(expected_uri)

            Config.token_uri = preserved_uri
          end

        end

        describe :api_secret do
          around do |example|
            original_value = Config.api_secret
            Config.api_secret = 'totallyfakesecret'
            example.run
            Config.api_secret = original_value
          end

          it 'is not nil' do
            expect(Config.api_secret).not_to be_nil
          end

          it 'can be set explicitly' do
            expected_secret = 'explicitly_set_secret'
            Config.api_secret = expected_secret
            expect(Config.api_secret).to eq(expected_secret)
          end
        end

        describe :api_key do
          it 'is not nil' do
            expect(Config.api_key).not_to be_nil
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

          context 'with Rails' do

            before do
              expect(defined?(Rails)).to be_nil # just to be sure

              rails = double(Object)
              Object.send(:const_set, 'Rails', rails)
            end

            after do
              Object.send(:remove_const, 'Rails')
            end

            context 'with full Rails config' do
              let(:rails_key) { '2lo55pdh7moyfodeo4gwgms0on65x31ghv0g6yg87ffwaljsdw' }
              let(:rails_secret) { 'totally_fake_secret' }

              before do
                app = double(Object)
                allow(Rails).to receive(:application).and_return(app)

                config = double(Object)
                allow(app).to receive(:config).and_return(config)

                allow(config).to receive(:worldcat_api_key).and_return(rails_key)
                allow(config).to receive(:worldcat_api_secret).and_return(rails_secret)
              end
              
              it 'reads config.worldcat_api_key' do
                # Overwrite the Config.api_key for this set of tests....
                Config.api_key = '2lo55pdh7moyfodeo4gwgms0on65x31ghv0g6yg87ffwaljsdw'
                expect(Config.api_key).to eq(rails_key)
              end

              it 'prefers $LIT_WORLDCAT_API_KEY even when config.worldcat_api_key is present' do
                expected_key = '2lo55pdh7moyfodeo4gwgms0on65x31ghv0g6yg87ffwaljsdw'.reverse
                allow(ENV).to receive(:[]).with('LIT_WORLDCAT_API_KEY').and_return(expected_key)
                expect(Config.api_key).to eq(expected_key)
              end
            end

            # These tests are no longer valid as the Config.api_key is now required for VCR
            context 'with partial Rails config' do
              # it "doesn't blow up if Rails exists but has no application" do
              #   allow(Rails).to receive(:application).and_return(nil)
              #   expect(Config.api_key).to be_nil
              # end

              # it "doesn't blow up if Rails configuration does not include URL" do
              #   app = double(Object)
              #   allow(Rails).to receive(:application).and_return(app)

              #   config = double(Object)
              #   allow(app).to receive(:config).and_return(config)

              #   expect(Config.api_key).to be_nil
              # end
            end

            
          end
        end

        describe :reset! do
          it "doesn't blow up if nothing was ever set" do
            expect { Config.send(:reset!) }.not_to raise_error
          end
        end
      end
    end
  end
end
