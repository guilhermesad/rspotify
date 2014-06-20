module RSpotify

  class Album < Base

    attr_accessor :album_type, :images, :name, :tracks

    def self.find(id)
      super(id, 'album')
    end

    def self.search(query, limit = 20, offset = 0)
      super(query, 'album', limit, offset)
    end

    def initialize(options = {})
      @album_type = options['album_type']
      @images     = options['images']
      @name       = options['name']

      if options['tracks']
        tracks = options['tracks']['items']
        @tracks = tracks.map { |t| Track.new t }
      end

      super(options)
    end

  end
end
