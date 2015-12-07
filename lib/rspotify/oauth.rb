require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Spotify < OmniAuth::Strategies::OAuth2
      option :name, 'spotify'

      option :client_options, {
        site:          RSpotify::API_URI,
        authorize_url: RSpotify::AUTHORIZE_URI,
        token_url:     RSpotify::TOKEN_URI,
      }

      uid { raw_info['id'] }

      info { raw_info }

      def raw_info
        @raw_info ||= access_token.get('me').parsed
      end
    end
  end
end
