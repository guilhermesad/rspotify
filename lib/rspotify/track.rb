module RSpotify

  class Track < Base

    attr_accessor :album, :artists, :available_markets, :disc_number, :duration_ms,
                  :explicit, :external_ids, :popularity, :preview_url, :track_number

    def self.find(id)
      super(id, 'track')
    end

    def self.search(query, limit = 20, offset = 0)
      super(query, 'track', limit, offset)
    end

    def initialize(options = {})
      @album             = Album.new options['album']
      @artists           = options['artists'].map { |a| Artist.new a }
      @available_markets = options['available_markets']
      @disc_number       = options['disc_number']
      @duration_ms       = options['duration_ms']
      @explicit          = options['explicit']
      @external_ids      = options['external_ids']
      @popularity        = options['popularity']
      @preview_url       = options['preview_url']
      @track_number      = options['track_number']

      super(options)
    end

  end
end
