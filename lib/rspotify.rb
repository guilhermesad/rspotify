require 'rspotify/version'

require 'base64'
require 'json'
require 'restclient'

module RSpotify

  API_URI   = 'https://api.spotify.com/v1/'
  TOKEN_URI = 'https://accounts.spotify.com/api/token'
  VERBS     = %w(get post put delete)

  autoload :Album,    'rspotify/album'
  autoload :Artist,   'rspotify/artist'
  autoload :Base,     'rspotify/base'
  autoload :Playlist, 'rspotify/playlist'
  autoload :Track,    'rspotify/track'
  autoload :User,     'rspotify/user'

  def self.authenticate(client_id, client_secret)
    request_body = { grant_type: 'client_credentials' }
    authorization = Base64.strict_encode64 "#{client_id}:#{client_secret}"
    headers = { 'Authorization' => "Basic #{authorization}" }
    response = RestClient.post(TOKEN_URI, request_body, headers)
    @access_token = JSON.parse(response)['access_token']
  end

  VERBS.each do |verb|

    define_singleton_method verb do |path, *params|
      url = API_URI + path
      response = RestClient.send(verb, url, *params)
      JSON.parse response
    end

    define_singleton_method "auth_#{verb}" do |path, *params|
      auth_header = { 'Authorization' => "Bearer #{@access_token}" }
      params << auth_header
      send(verb, path, *params)
    end

  end
end
