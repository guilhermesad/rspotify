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

      def callback_url
        if @authorization_code_from_signed_request_in_cookie
          ''
        else
          # Fixes regression in omniauth-oauth2 v1.4.0 by https://github.com/intridea/omniauth-oauth2/commit/85fdbe117c2a4400d001a6368cc359d88f40abc7
          # Spotify returns "Invalid redirect URI" if the `redirect_url` contains a query string
          options[:callback_url] || (full_host + script_name + callback_path)
        end
      end

      def raw_info
        @raw_info ||= access_token.get('me').parsed
      end
    end
  end
end
