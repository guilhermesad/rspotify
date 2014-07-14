module RSpotify

  # @attr [String] country      The country of the user, as set in the user's account profile. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. This field is only available when the current user has granted access to the *user-read-private* scope.
  # @attr [Hash]   credentials  The credentials generated for the user with OAuth. Includes access token, token type, token expiration time and refresh token. This field is only available when the current user has granted access to any scope.
  # @attr [String] display_name The name displayed on the user's profile. This field is only available when the current user has granted access to the *user-read-private* scope.
  # @attr [String] email        The user's email address. This field is only available when the current user has granted access to the *user-read-email* scope.
  # @attr [Array]  images       The user's profile image. This field is only available when the current user has granted access to the *user-read-private* scope.
  # @attr [String] product      The user's Spotify subscription level: "premium", "free", etc. This field is only available when the current user has granted access to the *user-read-private* scope.
  class User < Base

    # Returns User object with id provided
    #
    # @param id [String]
    # @return [User]
    #
    # @example
    #           user = RSpotify::User.find('wizzler')
    #           user.class #=> RSpotify::User
    #           user.id    #=> "wizzler"
    def self.find(id)
      super(id, 'user')
    end

    # Spotify does not support search for users. Prints warning and returns false
    def self.search(*)
      warn 'Spotify API does not support search for users'
      false
    end

    def self.oauth_header(user_id)
      { 
        'Authorization' => "Bearer #{@@users_credentials[user_id]['token']}",
        'Content-Type'  => 'application/json'
      }
    end
    private_class_method :oauth_header

    def initialize(options = {})
      credentials = options['credentials']
      options     = options['info'] if options['info']

      @country      ||= options['country']
      @display_name ||= options['display_name']
      @email        ||= options['email']
      @images       ||= options['images']
      @product      ||= options['product']

      super(options)

      if credentials
        @@users_credentials ||= {}
        @@users_credentials[@id] = credentials
        @credentials = @@users_credentials[@id]
      end
    end

    # Creates a playlist in user's Spotify account. This method is only available when the current user
    # has granted access to the *playlist-modify* and *playlist-modify-private* scopes.
    #
    # @param name [String] The name for the new playlist
    # @param public [Boolean] Whether the playlist is public or private. Default: true
    # @return [Playlist]
    #
    # @example
    #           user.create_playlist!('my-first-playlist')
    #           user.playlists.last.name   #=> "my-first-playlist"
    #           user.playlists.last.public #=> true
    #
    #           playlist = user.create_playlist!('my-second-playlist', public: false)
    #           playlist.name   #=> "my-second-playlist"
    #           playlist.public #=> false
    def create_playlist!(name, public: true)
      url = "users/#{@id}/playlists"
      request_data = %Q({"name":"#{name}", "public":#{public}})
      Playlist.new RSpotify.post(url, request_data, User.send(:oauth_header, @id))
    end

    # Returns all playlists from user
    #
    # @return [Array<Playlist>]
    #
    # @example
    #           playlists = user.playlists
    #           playlists.class       #=> Array
    #           playlists.first.class #=> RSpotify::Playlist
    #           playlists.first.name  #=> "Movie Soundtrack Masterpieces"
    def playlists
      playlists = RSpotify.auth_get("users/#{@id}/playlists")['items']
      playlists.map { |p| Playlist.new p }
    end

    # Returns a hash containing all user attributes
    def to_hash
      hash = {}
      instance_variables.each do |var|
        hash[var.to_s.delete('@')] = instance_variable_get(var)
      end
      hash
    end
  end
end
