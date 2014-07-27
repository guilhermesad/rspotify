module RSpotify

  # @attr [Boolean]      collaborative true if the owner allows other users to modify the playlist
  # @attr [String]       description   The playlist description
  # @attr [Hash]         followers     Information about the followers of the playlist
  # @attr [Array<Hash>]  images        The playlist images
  # @attr [String]       name          The name of the playlist
  # @attr [User]         owner         The user who owns the playlist
  # @attr [Boolean]      public        true if the playlist is not marked as secret
  # @attr [Array<Track>] tracks        The tracks of the playlist
  class Playlist < Base

    # Returns Playlist object with user_id and id provided
    #
    # @param user_id [String]
    # @param id [String]
    # @return [Playlist]
    #
    # @example
    #           playlist = RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX')
    #           playlist.class #=> RSpotify::Playlist
    #           playlist.name  #=> "Movie Soundtrack Masterpieces"
    def self.find(user_id, id)
      json = RSpotify.auth_get("users/#{user_id}/playlists/#{id}")
      Playlist.new json
    end

    # Spotify does not support search for playlists. Prints warning and returns false
    def self.search(*)
      warn 'Spotify API does not support search for playlists'
      false
    end

    def initialize(options = {})
      @collaborative = options['collaborative']
      @description   = options['description']
      @followers     = options['followers']
      @images        = options['images']
      @name          = options['name']
      @public        = options['public']

      @owner = if options['owner']
        User.new options['owner']
      end

      @tracks = if options['tracks'] && options['tracks']['items']
        options['tracks']['items'].map { |t| Track.new t['track'] }
      end

      super(options)
    end

    # Adds one or more tracks to a playlist in user's Spotify account. This method is only available when
    # the current user has granted access to the *playlist-modify* and *playlist-modify-private* scopes.
    # 
    # @param tracks [Array<Track>] Tracks to be added. Maximum: 100 per request
    # @param position [Integer, NilClass] The position to insert the tracks, a zero-based index. Default: tracks are appended to the playlist
    # @return [Array<Track>] The tracks added
    #
    # @example
    #           tracks = RSpotify::Track.search('Know', 30)
    #           playlist = user.create_playlist!('my-awesome-playlist')
    #
    #           playlist.add_tracks!(tracks)
    #           playlist.tracks.size       #=> 30
    #           playlist.tracks.first.name #=> "Somebody That I Used To Know"
    #
    #           playlist.add_tracks!(tracks, position: 20)
    #           playlist.tracks[20].name #=> "Somebody That I Used To Know"
    def add_tracks!(tracks, position: nil)
      if tracks.size > 100
        warn 'Too many tracks requested. Maximum: 100'
        return false
      end

      track_uris = tracks.map(&:uri).join(',')
      url = "users/#{@owner.id}/playlists/#{@id}/tracks?uris=#{track_uris}"
      url << "&position=#{position}" if position
      
      User.oauth_post(@owner.id, url, {})
      @tracks = nil
      tracks
    end

    # When an object is obtained undirectly, Spotify usually returns a simplified version of it.
    # This method updates it into a full object, with all attributes filled.
    # 
    # @note It is seldom necessary to use this method explicitly, since RSpotify takes care of it automatically when needed (see {Base#method_missing})
    #
    # @example
    #           playlist = user.playlists.first
    #           playlist.instance_variable_get("@description") #=> nil
    #           playlist.complete!
    #           playlist.instance_variable_get("@description") #=> "Iconic soundtracks..."
    def complete!
      url = "users/#{@owner.id}/playlists/#{@id}"
      credentials_defined = User.class_variable_defined?('@@users_credentials')
      credentials = (credentials_defined ? User.class_variable_get('@@users_credentials') : nil)

      if credentials && credentials[@owner.id]
        initialize User.oauth_get(@owner.id, url)
      else
        initialize RSpotify.auth_get(url)
      end
    end
  end
end
