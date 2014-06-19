require 'rspotify/version'

require 'json'
require 'restclient'

module RSpotify
  
  BASE_URI = 'https://api.spotify.com/v1/'
  VERBS = %w(get post put delete)

  autoload :Base,   'rspotify/base'
  autoload :Artist, 'rspotify/artist'
  autoload :Album,  'rspotify/album'
  autoload :Track,  'rspotify/track'
  
  VERBS.each do |verb|
    define_singleton_method verb do |path, *params|
      url = BASE_URI + path
      response = RestClient.send(verb, url, *params)
      JSON.parse response
    end
  end
end
