module RSpotify

  class Album < Base

    attr_accessor :album_type, :images, :tracks

    def self.find(id)
      super(id, 'album')
    end

    def self.search(query, limit = 20, offset = 0)
      super(query, 'album', limit, offset)
    end

    def initialize(options = {})
      @album_type = options['album_type']
      @images     = options['images']

      if options['tracks']
        @tracks = options['tracks']['items'].map { |t| Track.new (t) }
      end

      super(options)
    end

  end
end
