File.expand_path('lib', __dir__).tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

require 'berkeley_library/holdings/module_info'

Gem::Specification.new do |spec|
  spec.name = BerkeleyLibrary::Holdings::ModuleInfo::NAME
  spec.author = BerkeleyLibrary::Holdings::ModuleInfo::AUTHOR
  spec.email = BerkeleyLibrary::Holdings::ModuleInfo::AUTHOR_EMAIL
  spec.summary = BerkeleyLibrary::Holdings::ModuleInfo::SUMMARY
  spec.description = BerkeleyLibrary::Holdings::ModuleInfo::DESCRIPTION
  spec.license = BerkeleyLibrary::Holdings::ModuleInfo::LICENSE
  spec.version = BerkeleyLibrary::Holdings::ModuleInfo::VERSION
  spec.homepage = BerkeleyLibrary::Holdings::ModuleInfo::HOMEPAGE

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || %r{^(?:spec/|\.git)}
    end
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'berkeley_library-logging', '~> 0.2'
  spec.add_dependency 'rest-client', '~> 2.1'

  spec.add_development_dependency 'bundle-audit', '~> 0.1'
  spec.add_development_dependency 'ci_reporter_rspec', '~> 1.0'
  spec.add_development_dependency 'colorize', '~> 0.8'
  spec.add_development_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '= 1.39'
  spec.add_development_dependency 'rubocop-rake', '= 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '= 2.4.0'
  spec.add_development_dependency 'ruby-prof', '~> 0.17.0'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'simplecov-rcov', '~> 0.2'
  spec.add_development_dependency 'webmock', '~> 3.12'
end
