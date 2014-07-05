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

  spec.add_dependency 'omniauth-oauth2', '~> 1.1'
  spec.add_dependency 'rest_client', '~> 1.7'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fakeweb', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'yard'
end
