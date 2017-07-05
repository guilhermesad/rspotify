require 'base64'
require 'json'
require 'restclient'

module RSpotify

  API_URI       = 'https://api.spotify.com/v1/'
  AUTHORIZE_URI = 'https://accounts.spotify.com/authorize'
  TOKEN_URI     = 'https://accounts.spotify.com/api/token'
  VERBS         = %w(get post put delete)

  class << self
    attr_accessor :raw_response

    # Authenticates access to restricted data. Requires {https://developer.spotify.com/my-applications user credentials}
    #
    # @param client_id [String]
    # @param client_secret [String]
    #
    # @example
    #           RSpotify.authenticate("<your_client_id>", "<your_client_secret>")
    #
    #           playlist = RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX')
    #           playlist.name #=> "Movie Soundtrack Masterpieces"
    def authenticate(client_id, client_secret)
      @client_id, @client_secret = client_id, client_secret
      request_body = { grant_type: 'client_credentials' }
      response = RestClient.post(TOKEN_URI, request_body, auth_header)
      @client_token = JSON.parse(response)['access_token']
      true
    end

    VERBS.each do |verb|
      define_method verb do |path, *params|
        params << { 'Authorization' => "Bearer #{@client_token}" } if @client_token
        send_request(verb, path, *params)
      end
    end

    def resolve_auth_request(user_id, url)
      users_credentials = if User.class_variable_defined?('@@users_credentials')
        User.class_variable_get('@@users_credentials')
      end

      if users_credentials && users_credentials[user_id]
        User.oauth_get(user_id, url)
      else
        get(url)
      end
    end

    private

    def send_request(verb, path, *params)
      url = path.start_with?('http') ? path : API_URI + path

      url, query = *url.split('?')
      url = URI::encode(url)
      url << "?#{query}" if query

      begin
        response = RestClient.send(verb, url, *params)
      rescue RestClient::Unauthorized
        if @client_token
          authenticate(@client_id, @client_secret)
          
          obj = params.find{|x| x.is_a?(Hash) && x['Authorization']}
          obj['Authorization'] = "Bearer #{@client_token}"
          
          response = retry_connection verb, url, params
        end
      end

      return response if raw_response
      JSON.parse response unless response.empty?
    end
    
    # Added this method for testing
    def retry_connection verb, url, params
      RestClient.send(verb, url, *params)
    end

    def auth_header
      authorization = Base64.strict_encode64 "#{@client_id}:#{@client_secret}"
      { 'Authorization' => "Basic #{authorization}" }
    end
  end
end
