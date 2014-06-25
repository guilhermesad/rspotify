module RSpotify

  class Track < Base

    # Returns Track object(s) with id(s) provided
    #
    # @param ids [String, Array]
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
    # @param query [String]
    # @param limit [Integer]
    # @param offset [Integer]
    # @return [Array<Track>]
    #
    # @example
    #           tracks = RSpotify::Track.search('Thriller')
    #           tracks.size        #=> 20
    #           tracks.first.class #=> RSpotify::Track
    #           tracks.first.name  #=> "Thriller"
    #
    #           tracks = RSpotify::Track.search('Thriller', 10)
    #           tracks.size #=> 10
    def self.search(query, limit = 20, offset = 0)
      super(query, 'track', limit, offset)
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
