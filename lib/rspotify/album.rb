module RSpotify

  class Album < Base

    attr_accessor :album_type, :images

    def self.search(query, limit = 20, offset = 0)
      super(query, 'album', limit, offset)
    end

    def initialize(options = {})
      @album_type = options['album_type']
      @images     = options['images']

      super(options)
    end

  end
end
