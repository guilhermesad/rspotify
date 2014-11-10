module RSpotify

  # @attr [Boolean]      collaborative true if the owner allows other users to modify the playlist
  # @attr [String]       description   The playlist description
  # @attr [Hash]         followers     Information about the followers of the playlist
  # @attr [Array<Hash>]  images        The playlist images
  # @attr [String]       name          The name of the playlist
  # @attr [User]         owner         The user who owns the playlist
  # @attr [Boolean]      public        true if the playlist is not marked as secret
  class Playlist < Base

    # Returns Playlist object with user_id and id provided. If id is "starred", returns starred playlist from user.
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
      url = if id == "starred"
        "users/#{user_id}/starred"
      else
        "users/#{user_id}/playlists/#{id}"
      end
      json = RSpotify.resolve_auth_request(user_id, url)
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

      @tracks_cache = if options['tracks'] && options['tracks']['items']
        options['tracks']['items'].map { |i| Track.new i['track'] }
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
      track_uris = tracks.map(&:uri).join(',')
      url = @href + "/tracks?uris=#{track_uris}"
      url << "&position=#{position}" if position

      User.oauth_post(@owner.id, url, {})
      @tracks_cache = nil
      tracks
    end

    # Change name and public/private state of playlist in user's Spotify account. Changing a public playlist
    # requires the *playlist-modify* scope; changing a private playlist requires the *playlist-modify-private* scope.
    #
    # @param name   [String]  Optional. The new name for the playlist.
    # @param public [Boolean] Optional. If true the playlist will be public, if false it will be private.
    # @return [Playlist]
    #
    # @example
    #           playlist.name   #=> "Movie Soundtrack Masterpieces"
    #           playlist.public #=> true
    #
    #           playlist.change_details!(name: 'Movie Tracks', public: false)
    #
    #           playlist.name   #=> "Movie Tracks"
    #           playlist.public #=> false
    def change_details!(**data)
      User.oauth_put(@owner.id, @href, data.to_json)
      data.each do |field, value|
        instance_variable_set("@#{field}", value)
      end
      self
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
      initialize RSpotify.resolve_auth_request(@owner.id, @href)
    end

    # Returns array of tracks from the playlist
    #
    # @param limit  [Integer] Maximum number of tracks to return. Maximum: 100. Default: 100.
    # @param offset [Integer] The index of the first track to return. Use with limit to get the next set of objects. Default: 0.
    # @return [Array<Track>]
    #
    # @example
    #           playlist = RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX')
    #           playlist.tracks.first.name #=> "Main Theme from Star Wars - Instrumental"
    def tracks(limit: 100, offset: 0)
      last_track = offset + limit - 1
      if @tracks_cache && last_track < 100
        return @tracks_cache[offset..last_track]
      end

      url = @href + "/tracks?limit=#{limit}&offset=#{offset}"
      json = RSpotify.resolve_auth_request(@owner.id, url)

      tracks = json['items'].map do |i|
        Track.new i['track'] unless i['track'].nil?
      end.compact

      @tracks_cache = tracks if limit == 100 && offset == 0
      tracks
    end

    # Replace all the tracks in a playlist, overwriting its existing tracks. Changing a public playlist
    # requires the *playlist-modify* scope; changing a private playlist requires the *playlist-modify-private* scope.
    #
    # @param tracks [Array<Track>] The tracks that will replace the existing ones. Maximum: 100 per request
    # @return [Array<Track>] The tracks that were added.
    #
    # @example
    #           playlist.tracks.map(&:name) #=> ["All of Me", "Wasted Love", "Love Runs Out"]
    #           tracks = RSpotify::Track.search('Know', limit: 2)
    #           playlist.replace_tracks!(tracks)
    #           playlist.tracks.map(&:name) #=> ["Somebody That I Used To Know", "Do I Wanna Know?"]
    def replace_tracks!(tracks)
      track_uris = tracks.map(&:uri).join(',')
      url = @href + "/tracks?uris=#{track_uris}"
      User.oauth_put(@owner.id, url, {})
      @tracks_cache = nil
      tracks
    end
  end
end
