require 'addressable'
require 'base64'
require 'json'
require 'restclient'

module RSpotify
  class MissingAuthentication < StandardError; end

  API_URI       = 'https://api.spotify.com/v1/'.freeze
  AUTHORIZE_URI = 'https://accounts.spotify.com/authorize'.freeze
  TOKEN_URI     = 'https://accounts.spotify.com/api/token'.freeze
  VERBS         = %w[get post put delete].freeze

  class << self
    attr_accessor :raw_response
    attr_reader :client_token

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
        params << { 'Authorization' => "Bearer #{client_token}" } if client_token
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
      url = Addressable::URI.encode(url)
      url << "?#{query}" if query

      begin
        headers = get_headers(params)
        headers['Accept-Language'] = ENV['ACCEPT_LANGUAGE'] if ENV['ACCEPT_LANGUAGE']
        response = RestClient.send(verb, url, *params)
      rescue RestClient::Unauthorized => e
        raise e if request_was_user_authenticated?(*params)

        raise MissingAuthentication unless @client_id && @client_secret

        authenticate(@client_id, @client_secret)

        headers = get_headers(params)
        headers['Authorization'] = "Bearer #{@client_token}"

        response = retry_connection(verb, url, params)
      end

      return response if raw_response
      JSON.parse(response) unless response.nil? || response.empty?
    end

    # Added this method for testing
    def retry_connection(verb, url, params)
      RestClient.send(verb, url, *params)
    end

    def request_was_user_authenticated?(*params)
      users_credentials = if User.class_variable_defined?('@@users_credentials')
        User.class_variable_get('@@users_credentials')
      end

      headers = get_headers(params)
      if users_credentials
        creds = users_credentials.map{|_user_id, creds| "Bearer #{creds['token']}"}

        if creds.include?(headers['Authorization'])
          return true
        end
      end

      false
    end

    def auth_header
      authorization = Base64.strict_encode64("#{@client_id}:#{@client_secret}")
      { 'Authorization' => "Basic #{authorization}" }
    end

    def get_headers(params)
      params.find{|param| param.is_a?(Hash) && param['Authorization']}
    end
  end
end
