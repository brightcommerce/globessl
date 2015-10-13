require './lib/globessl/version'

Gem::Specification.new do |gem|
  gem.name         = 'globessl'
  gem.version      = GlobeSSL::VERSION::STRING
  gem.authors      = 'Jurgen Jocubeit'
  gem.email        = 'support@brightcommerce.com'
  gem.homepage     = 'https://github.com/brightcommerce/globessl'
  gem.summary      = GlobeSSL::VERSION::SUMMARY
  gem.description  = 'A Ruby API client for GlobeSSL CA resellers. This client provides almost all of the functionality exposed by v2 of their API.'
  gem.license      = 'MIT'
  gem.metadata     = { 'copyright' => 'Copyright 2015 Brightcommerce, Inc.' }
  gem.files        = `git ls-files`.split($/)
# gem.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_path = 'lib'
  gem.required_ruby_version = '>= 2.0.0'
  gem.add_dependency 'virtus', '~> 1.0.3'
end
