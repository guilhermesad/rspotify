module RSpotify

  # @attr [Array<String>] genres     A list of the genres used to classify the album (If not yet classified, the array is empty)
  # @attr [Array<Hash>]   images     The cover art for the album in various sizes, widest first
  # @attr [String]        name       The name of the album
  # @attr [Integer]       popularity The popularity of the album - The value will be between 0 and 100, with 100 being the most popular
  class Artist < Base

    # Returns Artist object(s) with id(s) provided
    #
    # @param ids [String, Array] Maximum: 50 IDs
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

    # Returns array of Artist objects matching the query, ordered by popularity
    #
    # @param query [String]
    # @param limit [Integer]
    # @param offset [Integer]
    # @return [Array<Artist>]
    #
    # @example
    #           artists = RSpotify::Artist.search('Arctic')
    #           artists.size        #=> 20
    #           artists.first.class #=> RSpotify::Artist
    #           artists.first.name  #=> "Arctic Monkeys"
    #
    #           artists = RSpotify::Artist.search('Arctic', 10)
    #           artists.size #=> 10
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

    # Returns all albums from artist
    #
    # @return [Array<Album>]
    #
    # @example
    #           albums = artist.albums
    #           albums.class       #=> Array
    #           albums.first.class #=> RSpotify::Album
    #           albums.first.name  #=> "AM"
    def albums
      return @albums unless @albums.nil?
      json = RSpotify.get("artists/#{@id}/albums")
      @albums = json['items'].map { |a| Album.new a }
    end

    # Returns artist's 10 top tracks by country.
    #
    # @param country [Symbol] an {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}
    # @return [Array<Track>]
    #
    # @example
    #           top_tracks = artist.top_tracks(:US)
    #           top_tracks.class       #=> Array
    #           top_tracks.size        #=> 10
    #           top_tracks.first.class #=> RSpotify::Track
    def top_tracks(country)
      return @top_tracks[country] unless @top_tracks[country].nil?
      json = RSpotify.get("artists/#{@id}/top-tracks?country=#{country}")
      @top_tracks[country] = json['tracks'].map { |t| Track.new t }
    end
  end
end
