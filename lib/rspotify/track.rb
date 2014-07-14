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
  class Track < Base

    # Returns Track object(s) with id(s) provided
    #
    # @param ids [String, Array] Maximum: 50 IDs
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
    def self.find(ids)
      super(ids, 'track')
    end

    # Returns array of Track objects matching the query, ordered by popularity
    #
    # @param query  [String]  The search query's keywords. See the q description in {https://developer.spotify.com/web-api/search-item here} for details.
    # @param limit  [Integer] Maximum number of tracks to return. Minimum: 1. Maximum: 50. Default: 20.
    # @param offset [Integer] The index of the first track to return. Use with limit to get the next set of tracks. Default: 0.
    # @return [Array<Track>]
    #
    # @example
    #           tracks = RSpotify::Track.search('Thriller')
    #           tracks.size        #=> 20
    #           tracks.first.class #=> RSpotify::Track
    #           tracks.first.name  #=> "Thriller"
    #
    #           tracks = RSpotify::Track.search('Thriller', limit: 10)
    #           tracks.size #=> 10
    def self.search(query, limit: 20, offset: 0)
      super(query, 'track', limit: limit, offset: offset)
    end

    def initialize(options = {})
      @available_markets = options['available_markets']
      @disc_number       = options['disc_number']
      @duration_ms       = options['duration_ms']
      @explicit          = options['explicit']
      @external_ids      = options['external_ids']
      @name              = options['name']
      @popularity        = options['popularity']
      @preview_url       = options['preview_url']
      @track_number      = options['track_number']

      @album = if options['album']
        Album.new options['album']
      end

      @artists = if options['artists']
        options['artists'].map { |a| Artist.new a }
      end

      super(options)
    end
  end
end
