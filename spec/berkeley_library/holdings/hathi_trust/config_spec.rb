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
              let(:rails_url) { 'https://catalog.hathitrust.test/api' }
              let(:rails_uri) { URI.parse(rails_url) }

              before do
                app = double(Object)
                allow(Rails).to receive(:application).and_return(app)

                config = double(Object)
                allow(app).to receive(:config).and_return(config)

                allow(config).to receive(:hathitrust_base_url).and_return(rails_url)
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

            context 'with partial Rails config' do
              it "doesn't blow up if Rails exists but has no application" do
                allow(Rails).to receive(:application).and_return(nil)
                expect(Config.base_uri.to_s).to eq(Config::DEFAULT_HATHITRUST_BASE_URL)
              end

              it "doesn't blow up if Rails configuration does not include URL" do
                app = double(Object)
                allow(Rails).to receive(:application).and_return(app)

                config = double(Object)
                allow(app).to receive(:config).and_return(config)

                expect(Config.base_uri.to_s).to eq(Config::DEFAULT_HATHITRUST_BASE_URL)
              end
            end
          end
        end

        describe :reset! do
          it "doesn't blow up if URI was never set" do
            expect { Config.send(:reset!) }.not_to raise_error
          end
        end
      end
    end
  end
end
