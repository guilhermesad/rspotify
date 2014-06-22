module RSpotify

  class Album < Base

    def self.find(id)
      super(id, 'album')
    end

    def self.search(query, limit = 20, offset = 0)
      super(query, 'album', limit, offset)
    end

    def initialize(options = {})
      @album_type             = options['album_type']
      @available_markets      = options['available_markets']
      @external_ids           = options['external_ids']
      @genres                 = options['genres']
      @images                 = options['images']
      @name                   = options['name']
      @popularity             = options['popularity']
      @release_date           = options['release_date']
      @release_date_precision = options['release_date_precision']

      if options['artists']
        artists = options['artists']
        @artists = artists.map { |a| Artist.new a }
      end

      if options['tracks']
        tracks = options['tracks']['items']
        @tracks = tracks.map { |t| Track.new t }
      end

      super(options)
    end

  end
end
