require 'base64'
require 'json'
require 'restclient'

module RSpotify

  API_URI       = 'https://api.spotify.com/v1/'
  AUTHORIZE_URI = 'https://accounts.spotify.com/authorize'
  TOKEN_URI     = 'https://accounts.spotify.com/api/token'
  VERBS         = %w(get post)

  def self.auth_header
    authorization = Base64.strict_encode64 "#{@client_id}:#{@client_secret}"
    { 'Authorization' => "Basic #{authorization}" }
  end
  private_class_method :auth_header

  def self.authenticate(client_id, client_secret)
    @client_id, @client_secret = client_id, client_secret
    request_body = { grant_type: 'client_credentials' }
    response = RestClient.post(TOKEN_URI, request_body, auth_header)
    @client_token = JSON.parse(response)['access_token']
    true
  end

  VERBS.each do |verb|
    define_singleton_method verb do |path, *params|
      url = API_URI + path
      response = RestClient.send(verb, url, *params)
      JSON.parse response unless response.empty?
    end

    define_singleton_method "auth_#{verb}" do |path, *params|
      auth_header = { 'Authorization' => "Bearer #{@client_token}" }
      params << auth_header
      send(verb, path, *params)
    end
  end
end
