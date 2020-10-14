module RSpotify

  # @attr [Boolean]     collaborative   true if the owner allows other users to modify the playlist
  # @attr [String]      description     The playlist description
  # @attr [Hash]        followers       Information about the followers of the playlist
  # @attr [Array<Hash>] images          Images for the playlist. The array may be empty or contain up to three images. The images are returned by size in descending order. If returned, the source URL for the image is temporary and will expire in less than one day.
  # @attr [String]      name            The name of the playlist
  # @attr [User]        owner           The user who owns the playlist
  # @attr [Boolean]     public          true if the playlist is not marked as secret
  # @attr [String]      snapshot_id     The version identifier for the current playlist. This attribute gets updated every time the playlist changes and can be supplied in other requests to target a specific playlist version
  # @attr [Integer]     total           The total number of tracks in the playlist
  # @attr [Hash]        tracks_added_at A hash containing the date and time each track was added to the playlist. Note: the hash is updated only when {#tracks} is used.
  # @attr [Hash]        tracks_added_by A hash containing the user that added each track to the playlist. Note: the hash is updated only when {#tracks} is used.
  # @attr [Hash]        tracks_is_local A hash showing whether each track is local or not. Note: the hash is updated only when {#tracks} is used.
  class Playlist < Base

    # Get a list of Spotify featured playlists (shown, for example, on a Spotify player’s “Browse” tab).
    #
    # @param limit    [Integer] Maximum number of playlists to return. Maximum: 50. Default: 20.
    # @param offset   [Integer] The index of the first playlist to return. Use with limit to get the next set of playlists. Default: 0.
    # @param country   [String] Optional. A country: an {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. Provide this parameter if you want the list of returned playlists to be relevant to a particular country. If omitted, the returned playlists will be relevant to all countries.
    # @param locale    [String] Optional. The desired language, consisting of a lowercase {http://en.wikipedia.org/wiki/ISO_639 ISO 639 language code} and an uppercase {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}, joined by an underscore. For details access {https://developer.spotify.com/web-api/get-list-featured-playlists/ here} and look for the locale parameter description.
    # @param timestamp [String] Optional. A timestamp in {http://en.wikipedia.org/wiki/ISO_8601 ISO 8601} format: yyyy-MM-ddTHH:mm:ss. Use this parameter to specify the user's local time to get results tailored for that specific date and time in the day. If not provided, the response defaults to the current UTC time. Example: "2014-10-23T09:00:00" for a user whose local time is 9AM.
    # @return [Array<Playlist>]
    #
    # @example
    #           playlists = RSpotify::Playlist.browse_featured
    #           playlists = RSpotify::Playlist.browse_featured(locale: 'es_MX', limit: 10)
    #           playlists = RSpotify::Playlist.browse_featured(country: 'US', timestamp: '2014-10-23T09:00:00')
    def self.browse_featured(limit: 20, offset: 0, **options)
      url = "browse/featured-playlists?limit=#{limit}&offset=#{offset}"
      options.each do |option, value|
        url << "&#{option}=#{value}"
      end

      response = RSpotify.get(url)
      return response if RSpotify.raw_response
      response['playlists']['items'].map { |i| Playlist.new i }
    end

    # Returns Playlist object with user_id and id provided. If id is "starred", returns starred playlist from user.
    #
    # @param user_id [String]
    # @param id [String]
    # @param market [String] Optional. An {https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. Provide this parameter if you want to apply Track Relinking
    # @return [Playlist]
    #
    # @example
    #           playlist = RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX')
    #           playlist.class #=> RSpotify::Playlist
    #           playlist.name  #=> "Movie Soundtrack Masterpieces"
    def self.find(user_id, id, market: nil)
      url = "users/#{user_id}/"
      url << (id == 'starred' ? id : "playlists/#{id}")
      url << "?market=#{market}" if market

      response = RSpotify.resolve_auth_request(user_id, url)
      return response if RSpotify.raw_response
      Playlist.new response
    end

    # Returns Playlist object with id provided.
    #
    # @param id [String]
    # @param market [String] Optional. An {https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. Provide this parameter if you want to apply Track Relinking
    # @return [Playlist]
    #
    # @example
    #           playlist = RSpotify::Playlist.find_by_id('00wHcTN0zQiun4xri9pmvX')
    #           playlist.class #=> RSpotify::Playlist
    #           playlist.name  #=> "Movie Soundtrack Masterpieces"
    def self.find_by_id(id, market: nil)
      url = "playlists/#{id}"
      url << "?market=#{market}" if market
      response = RSpotify.resolve_auth_request(nil, url)
      return response if RSpotify.raw_response
      Playlist.new response
    end

    # Returns array of Playlist objects matching the query. It's also possible to find the total number of search results for the query
    #
    # @param query  [String]  The search query's keywords. See the q description in {https://developer.spotify.com/web-api/search-item here} for details.
    # @param limit  [Integer] Maximum number of playlists to return. Maximum: 50. Default: 20.
    # @param offset [Integer] The index of the first playlist to return. Use with limit to get the next set of playlists. Default: 0.
    # @return [Array<Playlist>]
    #
    # @example
    #           playlists = RSpotify::Playlist.search('Indie')
    #           playlists = RSpotify::Playlist.search('Indie', limit: 10)
    #
    #           RSpotify::Playlist.search('Indie').total #=> 14653
    def self.search(query, limit: 20, offset: 0)
      super(query, 'playlist', limit: limit, offset: offset)
    end

    def initialize(options = {})
      @collaborative = options['collaborative']
      @description   = options['description']
      @followers     = options['followers']
      @images        = options['images']
      @name          = options['name']
      @public        = options['public']
      @snapshot_id   = options['snapshot_id']
      @total         = options['tracks']['total']

      @owner = if options['owner']
        User.new options['owner']
      end

      tracks = options['tracks']['items'] if options['tracks']
      tracks.select! { |t| t['track'] } if tracks

      @tracks_cache = if tracks
        tracks.map { |t| Track.new t['track'] }
      end

      @tracks_added_at = hash_for(tracks, 'added_at') do |added_at|
        Time.parse added_at
      end

      @tracks_added_by = hash_for(tracks, 'added_by') do |added_by|
        User.new added_by
      end

      @tracks_is_local = hash_for(tracks, 'is_local') do |is_local|
        is_local
      end

      super(options)

      @path = "users/#{@owner.instance_variable_get('@id').gsub('?','')}/"
      @path << (@href =~ /\/starred$/ ? 'starred' : "playlists/#{@id}")
    end

    # Adds one or more tracks to a playlist in user's Spotify account. This method is only available when the
    # current user has granted access to the *playlist-modify-public* and *playlist-modify-private* scopes.
    #
    # @param tracks [Array<Track>, Array<String>] Tracks to be added. Either array of Tracks or strings where each string is a valid spotify track uri. Maximum: 100 per request
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
      track_uris = nil
      if tracks.first.is_a? String
        track_uris = tracks.join(',')
      else
        track_uris = tracks.map(&:uri).join(',')
      end
      url = "#{@path}/tracks?uris=#{track_uris}"
      url << "&position=#{position}" if position

      response = User.oauth_post(@owner.id, url, {}.to_json)
      @total += tracks.size
      @tracks_cache = nil

      if RSpotify::raw_response
        @snapshot_id = JSON.parse(response)['snapshot_id']
        return response
      end

      @snapshot_id = response['snapshot_id']
      tracks
    end

    # Change name and public/private state of playlist in user's Spotify account. Changing a public playlist requires
    # the *playlist-modify-public* scope; changing a private playlist requires the *playlist-modify-private* scope.
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
      User.oauth_put(@owner.id, @path, data.to_json)
      data.each do |field, value|
        instance_variable_set("@#{field}", value)
      end
      @snapshot_id = nil
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
      initialize RSpotify.resolve_auth_request(@owner.id, @path)
    end

    # Check if one or more Spotify users are following a specified playlist. Checking if the user is privately
    # following a playlist is only possible if he/she has granted access to the *playlist-read-private* scope.
    #
    # @param users [Array<User>] The users to check. Maximum: 5.
    # @return [Array<Boolean>]
    #
    # @example
    #           user1 = RSpotify::User.find('<some-id>')
    #           user2 = RSpotify::User.find('<some-other-id>')
    #           playlist.is_followed_by?([user1, user2]) #=> [true, true] (Users publicly following playlist)
    #
    #           oauth-user = RSpotify::User.new(request.env['omniauth.auth']) # (See OAuth section in readme)
    #           playlist.is_followed_by?([oauth-user]) #=> [true] (User publicly or privately following playlist)
    def is_followed_by?(users)
      user_ids = users.map(&:id).join(',')
      url = "#{@path}/followers/contains?ids=#{user_ids}"

      users_credentials = if User.class_variable_defined?('@@users_credentials')
        User.class_variable_get('@@users_credentials')
      end

      auth_users = users.select do |user|
        users_credentials[user.id]
      end if users_credentials

      if auth_users && auth_users.any?
        User.oauth_get(auth_users.first.id, url)
      else
        RSpotify.get(url)
      end
    end

    # Returns array of tracks from the playlist
    #
    # @param limit  [Integer] Maximum number of tracks to return. Maximum: 100. Default: 100.
    # @param offset [Integer] The index of the first track to return. Use with limit to get the next set of objects. Default: 0.
    # @param market [String] Optional. An {https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. Provide this parameter if you want to apply Track Relinking
    # @return [Array<Track>]
    #
    # @example
    #           playlist = RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX')
    #           playlist.tracks.first.name #=> "Main Theme from Star Wars - Instrumental"
    def tracks(limit: 100, offset: 0, market: nil)
      last_track = offset + limit - 1
      if @tracks_cache && last_track < 100 && !RSpotify.raw_response
        return @tracks_cache[offset..last_track]
      end

      url = "#{@href}/tracks?limit=#{limit}&offset=#{offset}"
      url << "&market=#{market}" if market
      response = RSpotify.resolve_auth_request(@owner.id, url)

      json = RSpotify.raw_response ? JSON.parse(response) : response
      tracks = json['items'].select { |i| i['track'] }

      @tracks_added_at = hash_for(tracks, 'added_at') do |added_at|
        Time.parse added_at
      end

      @tracks_added_by = hash_for(tracks, 'added_by') do |added_by|
        User.new added_by
      end

      @tracks_is_local = hash_for(tracks, 'is_local') do |is_local|
        is_local
      end

      tracks.map! { |t| Track.new t['track'] }
      @tracks_cache = tracks if limit == 100 && offset == 0
      return response if RSpotify.raw_response
      tracks
    end

    # Remove one or more tracks from a user’s playlist. Removing from a public playlist requires the
    # *playlist-modify-public* scope; removing from a private playlist requires the *playlist-modify-private* scope.
    #
    # @param tracks [Array<Track,Hash>, Array<Integer>] Tracks to be removed. Maximum: 100 per request
    # @param snapshot_id [String] Optional. The playlist's snapshot ID against which you want to make the changes.
    # @return [Playlist]
    #
    # @example
    #           # Remove all occurrences of one or more tracks
    #           love_tracks = RSpotify::Track.search('Love')
    #           playlist.remove_tracks!(love_tracks)
    #
    #           # Remove specific occurrences of one or more tracks
    #           track = RSpotify::Track.find('tR3oH...')
    #           playlist.remove_tracks!([{track: track, positions: [0,3]}, other_track])
    #
    #           # Remove tracks based only on their positions (requires snapshot id)
    #           positions = [0,3,8]
    #           playlist.remove_tracks!(positions, snapshot_id: '0ZvtH...')
    def remove_tracks!(tracks, snapshot_id: nil)
      positions = tracks if tracks.first.is_a? Integer

      tracks = tracks.map do |track|
        next { uri: track.uri } if track.is_a? Track
        {
          uri: track[:track].uri,
          positions: track[:positions]
        }
      end unless positions

      params = {
        method: :delete,
        url: URI::encode(RSpotify::API_URI + @path + '/tracks'),
        headers: User.send(:oauth_header, @owner.id),
        payload: positions ? { positions: positions } : { tracks: tracks }
      }

      params[:payload][:snapshot_id] = snapshot_id if snapshot_id
      params[:payload] = params[:payload].to_json
      response = RestClient::Request.execute(params)

      @snapshot_id = JSON.parse(response)['snapshot_id']
      @tracks_cache = nil
      self
    end

    # Reorder a track or a group of tracks in a playlist. Changing a public playlist requires the
    # *playlist-modify-public* scope; changing a private playlist requires the *playlist-modify-private* scope.
    #
    # @param range_start   [Integer] The position of the first track to be reordered.
    # @param insert_before [Integer] The position where the tracks should be inserted. To reorder the tracks to the end of the playlist, simply set insert_before to the position after the last track.
    # @param range_length  [Integer] Optional. The amount of tracks to be reordered. Default: 1.
    # @param snapshot_id   [String]  Optional. The playlist's snapshot ID against which you want to make the changes.
    # @return [Playlist]
    #
    # @example
    #           range_start = 10
    #           insert_before = 0
    #           # Move the tracks at index 10-14 to the start of the playlist
    #           playlist.reorder_tracks!(range_start, insert_before, range_length: 5)
    def reorder_tracks!(range_start, insert_before, **options)
      url = "#{@path}/tracks"
      data = {
        range_start: range_start,
        insert_before: insert_before
      }.merge options

      response = User.oauth_put(@owner.id, url, data.to_json)
      json = RSpotify.raw_response ? JSON.parse(response) : response

      @snapshot_id = json['snapshot_id']
      @tracks_cache = nil
      self
    end

    # Replace the image used to represent a specific playlist. Requires ugc-image-upload scope. Changing a public playlist
    # requires the *playlist-modify-public* scope; changing a private playlist requires the *playlist-modify-private* scope.
    #
    # @param image [String] Base64 encoded JPEG image data, maximum payload size is 256 KB
    # @param content_type [String] The content type of the request body, e.g. "image/jpeg"
    # @return [NilClass] When the image has been provided, Spofity forwards it on to their transcoder service in order to generate the three sizes provided in the playlist’s images object. This operation takes some time, that's why nothing is returned for this method.
    #
    # @example
    #           playlist.replace_image!('SkZJRgABA...', 'image/jpeg')
    def replace_image!(image, content_type)
      url = "#{@path}/images"
      headers = {
        'Content-Type' => content_type
      }
      User.oauth_put(@owner.id, url, image, { headers: headers })
      nil
    end

    # Replace all the tracks in a playlist, overwriting its existing tracks. Changing a public playlist requires
    # the *playlist-modify-public* scope; changing a private playlist requires the *playlist-modify-private* scope.
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
      url = "#{@path}/tracks?uris=#{track_uris}"
      User.oauth_put(@owner.id, url, {}.to_json)

      @total = tracks.size
      @tracks_cache = nil
      @snapshot_id = nil
      tracks
    end

  end
end
