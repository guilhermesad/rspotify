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

      info do
        access_token.get('me').parsed
      end
    end
  end
end
