module RSpotify

  # @attr [String] birthdate       The user's date-of-birth. This field is only available when the current user has granted access to the *user-read-birthdate* scope.
  # @attr [String] country         The country of the user, as set in the user's account profile. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. This field is only available when the current user has granted access to the *user-read-private* scope.
  # @attr [Hash]   credentials     The credentials generated for the user with OAuth. Includes access token, token type, token expiration time and refresh token. This field is only available when the current user has granted access to any scope.
  # @attr [String] display_name    The name displayed on the user's profile. This field is only available when the current user has granted access to the *user-read-private* scope.
  # @attr [String] email           The user's email address. This field is only available when the current user has granted access to the *user-read-email* scope.
  # @attr [Hash]   followers       Information about the followers of the user
  # @attr [Array]  images          The user's profile image. This field is only available when the current user has granted access to the *user-read-private* scope.
  # @attr [String] product         The user's Spotify subscription level: "premium", "free", etc. This field is only available when the current user has granted access to the *user-read-private* scope.
  # @attr [Hash]   tracks_added_at A hash containing the date and time each track was saved by the user. Note: the hash is filled and updated only when {#saved_tracks} is used.
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

    # Spotify does not support search for users.
    def self.search(*)
      warn 'Spotify API does not support search for users'
      false
    end

    def self.refresh_token(user_id)
      request_body = {
        grant_type: 'refresh_token',
        refresh_token: @@users_credentials[user_id]['refresh_token']
      }
      response = RestClient.post(TOKEN_URI, request_body, RSpotify.send(:auth_header))
      response = JSON.parse(response)
      @@users_credentials[user_id]['token'] = response['access_token']
      access_refresh_proc = @@users_credentials[user_id]['access_refresh_callback']
      # If the access token expires and a new one is granted via the refresh
      # token, then this proc will be called with two parameters:
      # new_access_token and token_lifetime (in seconds)
      # The purpose is to allow the calling environment to invoke some action,
      # such as persisting the new access token somewhere, when the new token
      # is generated.
      if (access_refresh_proc.respond_to? :call)
        access_refresh_proc.call(response['access_token'], response['expires_in'])
      end
    rescue RestClient::BadRequest => e
      raise e if e.response !~ /Refresh token revoked/
    end
    private_class_method :refresh_token

    def self.extract_custom_headers(params)
      headers_param = params.find{|x| x.is_a?(Hash) && x[:headers]}
      params.delete(headers_param) if headers_param
      headers_param ? headers_param[:headers] : {}
    end
    private_class_method :extract_custom_headers

    def self.oauth_header(user_id)
      {
        'Authorization' => "Bearer #{@@users_credentials[user_id]['token']}",
        'Content-Type'  => 'application/json'
      }
    end
    private_class_method :oauth_header

    def self.oauth_send(user_id, verb, path, *params)
      custom_headers = extract_custom_headers(params)
      headers = oauth_header(user_id).merge(custom_headers)
      params << headers
      RSpotify.send(:send_request, verb, path, *params)

    rescue RestClient::Exception => e
      raise e if e.response !~ /access token expired/
      refresh_token(user_id)
      params[-1] = oauth_header(user_id).merge(custom_headers)
      RSpotify.send(:send_request, verb, path, *params)
    end
    private_class_method :oauth_send

    RSpotify::VERBS.each do |verb|
      define_singleton_method "oauth_#{verb}" do |user_id, path, *params|
        oauth_send(user_id, verb, path, *params)
      end
    end

    def initialize(options = {})
      credentials = options['credentials']
      extra       = options['extra'].to_h
      options     = options['info'] if options['info']
      options.merge!(extra['raw_info'].to_h)

      @birthdate    ||= options['birthdate']
      @country      ||= options['country']
      @display_name ||= options['display_name']
      @email        ||= options['email']
      @followers    ||= options['followers']
      @images       ||= options['images']
      @product      ||= options['product']

      super(options)

      if credentials
        @@users_credentials ||= {}
        @@users_credentials[@id] = credentials
        @credentials = @@users_credentials[@id]
      end
    end

    # Creates a playlist in user's Spotify account. This method is only available when the current
    # user has granted access to the *playlist-modify-public* and *playlist-modify-private* scopes.
    #
    # @note To create a collaborative playlist the public option must be set to false.
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
    def create_playlist!(name, description: nil, public: true, collaborative: false)
      url = "users/#{@id}/playlists"
      request_data = {
        name: name,
        public: public,
        description: description,
        collaborative: collaborative
      }.to_json
      response = User.oauth_post(@id, url, request_data)
      return response if RSpotify.raw_response
      Playlist.new response
    end

    # Get the current user’s player
    #
    # @example
    #           player = user.player
    def player
      url = "me/player"
      response = User.oauth_get(@id, url)
      return response if RSpotify.raw_response
      response ? Player.new(self, response) : Player.new(self)
    end

    # Get the current user’s recently played tracks. Requires the *user-read-recently-played* scope.
    #
    # @param limit  [Integer] Optional. The number of entities to return. Default: 20. Minimum: 1. Maximum: 50.
    # @param after  [String] Optional. A Unix timestamp in milliseconds. Returns all items after (but not including) this cursor position. If after is specified, before must not be specified.
    # @param before [String] Optional. A Unix timestamp in milliseconds. Returns all items before (but not including) this cursor position. If before is specified, after must not be specified.
    # @return [Array<Track>]
    #
    # @example
    #           recently_played = user.recently_played
    #           recently_played.size       #=> 20
    #           recently_played.first.name #=> "Ice to Never"
    #           user.recently_played(limit: 50)
    #           user.recently_played(after: '1572561234', before: '1572562369')
    def recently_played(limit: 20, after: nil, before: nil)
      url = "me/player/recently-played?limit=#{limit}"
      url << "&after=#{after}" if after
      url << "&before=#{before}" if before

      response = RSpotify.resolve_auth_request(@id, url)
      return response if RSpotify.raw_response

      json = RSpotify.raw_response ? JSON.parse(response) : response
      json['items'].map do |t|
        data = t['track']
        data['played_at'] = t['played_at']
        data['context_type'] = t['context']['type'] if t['context']
        Track.new data
      end
    end

    # Add the current user as a follower of one or more artists, other Spotify users or a playlist. Following artists or users require the *user-follow-modify*
    # scope. Following a playlist publicly requires the *playlist-modify-public* scope; following it privately requires the *playlist-modify-private* scope.
    #
    # @note Scopes you provide for playlists determine only whether the current user can themselves follow the playlist publicly or privately (i.e. show others what they are following), not whether the playlist itself is public or private.
    #
    # @param followed [Artist, Array<Artist>, User, Array<User>, Playlist] The artists, users or playlist to follow
    # @param public [Boolean] If true the playlist will be included in user's public playlists, if false it will remain private.
    # @return [Artist, Array<Artist>, User, Array<User>, Playlist]
    #
    # @example
    #           artists = RSpotify::Artist.search('John')
    #           user.follow(artists)
    #
    #           playlist = RSpotify::Playlist.search('Movie').first
    #           user.follow(playlist, public: false)
    def follow(followed, public: true)
      if followed.is_a? Array
        ids = followed.map(&:id).join(',')
        type = followed.first.type
      else
        ids = followed.id
        type = followed.type
      end

      if type == 'playlist'
        request_body = { public: public }
        url = "users/#{followed.owner.id}/playlists/#{followed.id}/followers"
      else
        request_body = {}
        url = "me/following?type=#{type}&ids=#{ids}"
      end

      User.oauth_put(@id, url, request_body.to_json)
      followed
    end

    # Get the current user’s followed artists or users. Requires the *user-follow-read* scope.
    #
    # @note The current Spotify API implementation only supports getting followed *artists*
    #
    # @param type  [String]  The ID type: currently only "artist" is supported
    # @param limit [Integer] Maximum number of items to return. Maximum: 50. Minimum: 1. Default: 20.
    # @param after [String]  Optional. The last artist ID retrieved from the previous request.
    # @return [Array<Artist>]
    #
    # @example
    #           followed_artists = user.following(type: 'artist')
    #           followed_artists.first.class #=> RSpotify::Artist
    #
    #           followed_artists = user.following(type: 'artist', limit: 50)
    def following(type: nil, limit: 20, after: nil)
      type_class = RSpotify.const_get(type.capitalize)
      url = "me/following?type=#{type}&limit=#{limit}"
      url << "&after=#{after}" if after

      response = User.oauth_get(@id, url)
      return response if RSpotify.raw_response
      response["#{type}s"]['items'].compact.map { |i| type_class.new i }
    end

    # Check if the current user is following one or more artists or other Spotify users. This method
    # is only available when the current user has granted access to the *user-follow-read* scope.
    #
    # @param followed [Artist, Array<Artist>, User, Array<User>] The users or artists to check
    # @return [Array<Boolean>]
    #
    # @example
    #           artists = RSpotify::Artist.search('John')
    #           user.follows?(artists) #=> [true, false, true...]
    def follows?(followed)
      if followed.is_a? Array
        ids = followed.map(&:id).join(',')
        type = followed.first.type
      else
        ids = followed.id
        type = followed.type
      end

      url = "me/following/contains?type=#{type}&ids=#{ids}"
      User.oauth_get(@id, url)
    end

    # Returns all playlists from user
    #
    # @param limit  [Integer] Maximum number of playlists to return. Maximum: 50. Minimum: 1. Default: 20.
    # @param offset [Integer] The index of the first playlist to return. Use with limit to get the next set of playlists. Default: 0.
    # @return [Array<Playlist>]
    #
    # @example
    #           playlists = user.playlists
    #           playlists.class       #=> Array
    #           playlists.first.class #=> RSpotify::Playlist
    #           playlists.first.name  #=> "Movie Soundtrack Masterpieces"
    def playlists(limit: 20, offset: 0)
      url = "users/#{@id}/playlists?limit=#{limit}&offset=#{offset}"
      response = RSpotify.resolve_auth_request(@id, url)
      return response if RSpotify.raw_response
      response['items'].map { |i| Playlist.new i }
    end

    # Remove tracks from the user’s “Your Music” library.
    #
    # @param tracks [Array<Track>] The tracks to remove. Maximum: 50.
    # @return [Array<Track>] The tracks removed.
    #
    # @example
    #           tracks = user.saved_tracks
    #
    #           user.saved_tracks.size #=> 20
    #           user.remove_tracks!(tracks)
    #           user.saved_tracks.size #=> 0
    def remove_tracks!(tracks)
      tracks_ids = tracks.map(&:id)
      url = "me/tracks?ids=#{tracks_ids.join ','}"
      User.oauth_delete(@id, url)
      tracks
    end

    # Save tracks to the user’s “Your Music” library.
    #
    # @param tracks [Array<Track>] The tracks to save. Maximum: 100.
    # @return [Array<Track>] The tracks saved.
    #
    # @example
    #           tracks = RSpotify::Track.search('Know')
    #
    #           user.saved_tracks.size #=> 0
    #           user.save_tracks!(tracks)
    #           user.saved_tracks.size #=> 20
    def save_tracks!(tracks)
      tracks_ids = tracks.map(&:id)
      url = "me/tracks"
      request_body = tracks_ids.inspect
      User.oauth_put(@id, url, request_body)
      tracks
    end

    # Returns the tracks saved in the Spotify user’s “Your Music” library
    #
    # @param limit  [Integer] Maximum number of tracks to return. Maximum: 50. Minimum: 1. Default: 20.
    # @param offset [Integer] The index of the first track to return. Use with limit to get the next set of tracks. Default: 0.
    # @param market [String]  Optional. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}.
    # @return [Array<Track>]
    #
    # @example
    #           tracks = user.saved_tracks
    #           tracks.size       #=> 20
    #           tracks.first.name #=> "Do I Wanna Know?"
    def saved_tracks(limit: 20, offset: 0, market: nil)
      url = "me/tracks?limit=#{limit}&offset=#{offset}"
      url << "&market=#{market}" if market
      response = User.oauth_get(@id, url)
      json = RSpotify.raw_response ? JSON.parse(response) : response

      tracks = json['items'].select { |i| i['track'] }
      @tracks_added_at = hash_for(tracks, 'added_at') do |added_at|
        Time.parse added_at
      end

      return response if RSpotify.raw_response
      tracks.map { |t| Track.new t['track'] }
    end

    # Check if tracks are already saved in the Spotify user’s “Your Music” library
    #
    # @param tracks [Array<Track>] The tracks to check. Maximum: 50.
    # @return [Array<Boolean>] Array of booleans, in the same order in which the tracks were specified.
    #
    # @example
    #           tracks = RSpotify::Track.search('Know')
    #           user.saved_tracks?(tracks) #=> [true, false, true...]
    def saved_tracks?(tracks)
      tracks_ids = tracks.map(&:id)
      url = "me/tracks/contains?ids=#{tracks_ids.join ','}"
      User.oauth_get(@id, url)
    end

    # Remove albums from the user’s “Your Music” library.
    #
    # @param albums [Array<Album>] The albums to remove. Maximum: 50.
    # @return [Array<Album>] The albums removed.
    #
    # @example
    #           albums = user.saved_albums
    #
    #           user.saved_albums.size #=> 20
    #           user.remove_albums!(albums)
    #           user.saved_albums.size #=> 0
    def remove_albums!(albums)
      albums_ids = albums.map(&:id)
      url = "me/albums?ids=#{albums_ids.join ','}"
      User.oauth_delete(@id, url)
      albums
    end

    # Save albums to the user’s “Your Music” library.
    #
    # @param albums [Array<Album>] The albums to save. Maximum: 50.
    # @return [Array<Album>] The albums saved.
    #
    # @example
    #           albums = RSpotify::Album.search('launeddas')
    #
    #           user.saved_albums.size #=> 0
    #           user.save_albums!(albums)
    #           user.saved_albums.size #=> 10
    def save_albums!(albums)
      albums_ids = albums.map(&:id)
      url = "me/albums"
      request_body = albums_ids.inspect
      User.oauth_put(@id, url, request_body)
      albums
    end

    # Returns the albums saved in the Spotify user’s “Your Music” library. ** Includes albums whose tracks you saved
    #
    # @param limit  [Integer] Maximum number of albums to return. Maximum: 50. Minimum: 1. Default: 20.
    # @param offset [Integer] The index of the first album to return. Use with limit to get the next set of albums. Default: 0.
    # @param market [String]  Optional. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}.
    # @return [Array<Album>]
    #
    # @example
    #           albums = user.saved_albums
    #           albums.size       #=> 20
    #           albums.first.name #=> "Launeddas"
    def saved_albums(limit: 20, offset: 0, market: nil)
      url = "me/albums?limit=#{limit}&offset=#{offset}"
      url << "&market=#{market}" if market
      response = User.oauth_get(@id, url)
      json = RSpotify.raw_response ? JSON.parse(response) : response

      albums = json['items'].select { |i| i['album'] }

      return response if RSpotify.raw_response
      albums.map { |a| Album.new a['album'] }
    end

    # Check if albums are already saved in the Spotify user’s “Your Music” library. ** Only returns true if the album was saved via me/albums, not if you saved each track individually.
    #
    # @param albums [Array<Album>] The albums to check. Maximum: 50.
    # @return [Array<Boolean>] Array of booleans, in the same order in which the albums were specified.
    #
    # @example
    #           albums = RSpotify::Album.search('launeddas')
    #           user.saved_albums?(albums) #=> [true, false, true...]
    def saved_albums?(albums)
      albums_ids = albums.map(&:id)
      url = "me/albums/contains?ids=#{albums_ids.join ','}"
      User.oauth_get(@id, url)
    end

    # Returns a hash containing all user attributes
    def to_hash
      pairs = instance_variables.map do |var|
        [var.to_s.delete('@'), instance_variable_get(var)]
      end
      Hash[pairs]
    end

    # Get the current user’s top artists based on calculated affinity. Requires the *user-top-read* scope.
    #
    # @param limit  [Integer] Optional. The number of entities to return. Default: 20. Minimum: 1. Maximum: 50.
    # @param offset [Integer] Optional. The index of the first entity to return. Default: 0 (i.e., the first track). Use with limit to get the next set of entities.
    # @param time_range [String] Optional. Over what time frame the affinities are computed. Valid values: long_term (calculated from several years of data and including all new data as it becomes available), medium_term (approximately last 6 months), short_term (approximately last 4 weeks). Default: medium_term.
    # @return [Array<Artist>]
    #
    # @example
    #           top_artists = user.top_artists
    #           top_artists.size       #=> 20
    #           top_artists.first.name #=> "Nine Inch Nails"
    def top_artists(limit: 20, offset: 0, time_range: 'medium_term')
      url = "me/top/artists?limit=#{limit}&offset=#{offset}&time_range=#{time_range}"
      response = User.oauth_get(@id, url)
      return response if RSpotify.raw_response
      response['items'].map { |i| Artist.new i }
    end

    # Get the current user’s top tracks based on calculated affinity. Requires the *user-top-read* scope.
    #
    # @param limit  [Integer] Optional. The number of entities to return. Default: 20. Minimum: 1. Maximum: 50.
    # @param offset [Integer] Optional. The index of the first entity to return. Default: 0 (i.e., the first track). Use with limit to get the next set of entities.
    # @param time_range [String] Optional. Over what time frame the affinities are computed. Valid values: long_term (calculated from several years of data and including all new data as it becomes available), medium_term (approximately last 6 months), short_term (approximately last 4 weeks). Default: medium_term.
    # @return [Array<Track>]
    #
    # @example
    #           top_tracks = user.top_tracks
    #           top_tracks.size       #=> 20
    #           top_tracks.first.name #=> "Ice to Never"
    def top_tracks(limit: 20, offset: 0, time_range: 'medium_term')
      url = "me/top/tracks?limit=#{limit}&offset=#{offset}&time_range=#{time_range}"
      response = User.oauth_get(@id, url)
      return response if RSpotify.raw_response
      response['items'].map { |i| Track.new i }
    end

    # Remove the current user as a follower of one or more artists, other Spotify users or a playlist. Unfollowing artists or users require the *user-follow-modify* scope.
    # Unfollowing a publicly followed playlist requires the *playlist-modify-public* scope; unfollowing a privately followed playlist requires the *playlist-modify-private* scope.
    #
    # @note Note that the scopes you provide for playlists relate only to whether the current user is following the playlist publicly or privately (i.e. showing others what they are following), not whether the playlist itself is public or private.
    #
    # @param unfollowed [Artist, Array<Artist>, User, Array<User>, Playlist] The artists, users or playlist to unfollow
    # @return [Artist, Array<Artist>, User, Array<User>, Playlist]
    #
    # @example
    #           artists = RSpotify::Artist.search('John')
    #           user.unfollow(artists)
    #
    #           playlist = RSpotify::Playlist.search('Movie').first
    #           user.unfollow(playlist)
    def unfollow(unfollowed)
      if unfollowed.is_a? Array
        ids = unfollowed.map(&:id).join(',')
        type = unfollowed.first.type
      else
        ids = unfollowed.id
        type = unfollowed.type
      end

      url = if type == 'playlist'
        "users/#{unfollowed.owner.id}/playlists/#{unfollowed.id}/followers"
      else
        "me/following?type=#{type}&ids=#{ids}"
      end

      User.oauth_delete(@id, url)
      unfollowed
    end

    # Returns the user's available devices
    #
    # @return [Array<Device>]
    #
    # @example
    #           devices = user.devices
    #           devices.first.id #=> "5fbb3ba6aa454b5534c4ba43a8c7e8e45a63ad0e"
    def devices
      url = "me/player/devices"
      response = RSpotify.resolve_auth_request(@id, url)

      return response if RSpotify.raw_response
      response['devices'].map { |i| Device.new i }
    end
  end
end
