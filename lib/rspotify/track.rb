module RSpotify

  # @attr [Album]         album             The album on which the track appears
  # @attr [Array<Artist>] artists           The artists who performed the track
  # @attr [Array<String>] available_markets The markets in which the track can be played. See {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country codes}
  # @attr [Integer]       disc_number       The disc number. Usually 1 unless the album consists of more than one disc
  # @attr [Integer]       duration_ms       The track length in milliseconds
  # @attr [Boolean]       explicit          Whether or not the track has explicit lyrics. true = yes it does; false = no it does not OR unknown
  # @attr [Hash]          external_ids      Known external IDs for the track
  # @attr [String]        name              The name of the track
  # @attr [Integer]       popularity        The popularity of the track. The value will be between 0 and 100, with 100 being the most popular
  # @attr [String]        preview_url       A link to a 30 second preview (MP3 format) of the track
  # @attr [Integer]       track_number      The number of the track. If an album has several discs, the track number is the number on the specified disc
  # @attr [String]        played_at         The date and time the track was played. Only present when pulled from /recently-played
  # @attr [String]        context_type      The context the track was played from. Only present when pulled from /recently-played
  # @attr [Boolean]       is_playable       Whether or not the track is playable in the given market. Only present when track relinking is applied by specifying a market when looking up the track
  # @attr [TrackLink]     linked_from       Details of the requested track. Only present when track relinking is applied and the returned track is different to the one requested because the latter is not available in the given market
  class Track < Base

    # Returns Track object(s) with id(s) provided
    #
    # @param ids [String, Array] Maximum: 50 IDs
    # @param market [String] Optional. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}.
    # @return [Track, Array<Track>]
    #
    # @example
    #           track = RSpotify::Track.find('2UzMpPKPhbcC8RbsmuURAZ')
    #           track.class #=> RSpotify::Track
    #           track.name  #=> "Do I Wanna Know?"
    #           
    #           ids = %w(2UzMpPKPhbcC8RbsmuURAZ 7Jzsc04YpkRwB1zeyM39wE)
    #           tracks = RSpotify::Base.find(ids, 'track')
    #           tracks.class       #=> Array
    #           tracks.first.class #=> RSpotify::Track
    def self.find(ids, market: nil)
      super(ids, 'track', market: market)
    end

    # Returns array of Track objects matching the query, ordered by popularity. It's also possible to find the total number of search results for the query
    #
    # @param query  [String]       The search query's keywords. For details access {https://developer.spotify.com/web-api/search-item here} and look for the q parameter description.
    # @param limit  [Integer]      Maximum number of tracks to return. Maximum: 50. Default: 20.
    # @param offset [Integer]      The index of the first track to return. Use with limit to get the next set of tracks. Default: 0.
    # @param market [String, Hash] Optional. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code} or the hash { from: user }, where user is a RSpotify user authenticated using OAuth with scope *user-read-private*. This will take the user's country as the market value. For details access {https://developer.spotify.com/web-api/search-item here} and look for the market parameter description.
    # @return [Array<Track>]
    #
    # @example
    #           tracks = RSpotify::Track.search('Wanna Know')
    #           tracks = RSpotify::Track.search('Wanna Know', limit: 10, market: 'US')
    #           tracks = RSpotify::Track.search('Wanna Know', market: { from: user })
    #
    #           RSpotify::Track.search('Wanna Know').total #=> 3686
    def self.search(query, limit: 20, offset: 0, market: nil)
      super(query, 'track', limit: limit, offset: offset, market: market)
    end

    # Retrieves the audio features for the track
    def audio_features
      RSpotify::AudioFeatures.find(@id)
    end

    def initialize(options = {})
      @available_markets = options['available_markets']
      @disc_number       = options['disc_number']
      @duration_ms       = options['duration_ms']
      @explicit          = options['explicit']
      @external_ids      = options['external_ids']
      @uri               = options['uri']
      @name              = options['name']
      @popularity        = options['popularity']
      @preview_url       = options['preview_url']
      @track_number      = options['track_number']
      @played_at         = options['played_at']
      @context_type      = options['context_type']
      @is_playable       = options['is_playable']

      @album = if options['album']
        Album.new options['album']
      end

      @artists = if options['artists']
        options['artists'].map { |a| Artist.new a }
      end

      @linked_from = if options['linked_from']
        TrackLink.new options['linked_from']
      end

      super(options)
    end
  end
end
