# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspotify/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspotify'
  spec.version       = RSpotify::VERSION
  spec.authors       = ['Guilherme Sad']
  spec.email         = ['gorgulhoguilherme@gmail.com']
  spec.summary       = %q{A ruby wrapper for the Spotify Web API}
  spec.homepage      = 'http://rubygems.org/gems/rspotify'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(/^spec\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'omniauth-oauth2', '>= 1.6'
  spec.add_dependency 'rest-client', '~> 2.0.2'
  spec.add_dependency 'addressable', '~> 2.5.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'vcr', '~> 3.0'

  spec.required_ruby_version = '>= 2.0.0'
end
