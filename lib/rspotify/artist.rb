module RSpotify

  class Artist < Base

    # Return Artist object(s) with id(s) provided
    #
    # @param ids [String, Array]
    # @return [Artist, Array<Artist>]
    #
    # @example
    #           artist = RSpotify::Artist.find('7Ln80lUS6He07XvHI8qqHH')
    #           artist.class #=> RSpotify::Artist
    #           artist.name  #=> "Arctic Monkeys"
    #           
    #           ids = %w(7Ln80lUS6He07XvHI8qqHH 3dRfiJ2650SZu6GbydcHNb)
    #           artists = RSpotify::Artist.find(ids)
    #           artists.class       #=> Array
    #           artists.first.class #=> RSpotify::Artist
    def self.find(ids)
      super(ids, 'artist')
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

    def albums
      return @albums unless @albums.nil?
      json = RSpotify.get("artists/#{@id}/albums")
      @albums = json['items'].map { |a| Album.new a }
    end

    def top_tracks(country)
      return @top_tracks[country] unless @top_tracks[country].nil?
      json = RSpotify.get("artists/#{@id}/top-tracks?country=#{country}")
      @top_tracks[country] = json['tracks'].map { |t| Track.new t }
    end
  end
end
