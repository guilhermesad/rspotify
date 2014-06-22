module RSpotify

  class Track < Base

    def self.find(id)
      super(id, 'track')
    end

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

      if options['album']
        @album = Album.new options['album']
      end

      if options['artists']
        artists = options['artists']
        @artists = artists.map { |a| Artist.new a }
      end

      super(options)
    end

  end
end
