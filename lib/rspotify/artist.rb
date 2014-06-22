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
      @top_tracks = {}

      super(options)
    end

    def top_tracks(country)
      return @top_tracks[country] unless @top_tracks[country].nil?
      json = RSpotify.get("artists/#{@id}/top-tracks?country=#{country}")
      @top_tracks[country] = json['tracks'].map{ |t| Track.new t }
    end
  end
end
