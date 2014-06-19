module RSpotify

  class Artist < Base

    attr_accessor :genres, :images, :name, :popularity

    def self.find(id)
      super(id, 'artist')
    end

    def self.search(query, limit = 20, offset = 0)
      super(query, 'artist', limit, offset)
    end

    def initialize(options = {})
      @genres     = options['genres']
      @images     = options['images']
      @name       = options['name']
      @popularity = options['popularity']

      super(options)
    end

  end
end
