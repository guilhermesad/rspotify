module RSpotify

  class Artist < Base

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

    def top_tracks(country)
      json = RSpotify.get("artists/#{@id}/top-tracks?country=#{country}")
      json['tracks'].map{ |t| Track.new t }
    end
  end
end
