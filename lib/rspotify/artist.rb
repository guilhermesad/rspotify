module RSpotify

  # @attr [Array<String>] genres     A list of the genres the artist is associated with. If not yet classified, the array is empty
  # @attr [Array<Hash>]   images     Images of the artist in various sizes, widest first
  # @attr [String]        name       The name of the artist
  # @attr [Integer]       popularity The popularity of the artist. The value will be between 0 and 100, with 100 being the most popular
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
    # @param query  [String]  The search query's keywords. See the q description in {https://developer.spotify.com/web-api/search-item here} for details.
    # @param limit  [Integer] Maximum number of artists to return. Maximum: 50. Default: 20.
    # @param offset [Integer] The index of the first artist to return. Use with limit to get the next set of artists. Default: 0.
    # @return [Array<Artist>]
    #
    # @example
    #           artists = RSpotify::Artist.search('Arctic')
    #           artists.size        #=> 20
    #           artists.first.class #=> RSpotify::Artist
    #           artists.first.name  #=> "Arctic Monkeys"
    #
    #           artists = RSpotify::Artist.search('Arctic', limit: 10)
    #           artists.size #=> 10
    def self.search(query, limit: 20, offset: 0, market: nil)
      super(query, 'artist', limit: limit, offset: offset, market: market)
    end

    def initialize(options = {})
      @genres     = options['genres']
      @images     = options['images']
      @name       = options['name']
      @popularity = options['popularity']
      @top_tracks = {}

      super(options)
    end

    # Returns array of albums from artist
    #
    # @param limit      [Integer] Maximum number of albums to return. Maximum: 50. Default: 20.
    # @param offset     [Integer] The index of the first album to return. Use with limit to get the next set of albums. Default: 0.
    # @param album_type [String]  Optional. A comma-separated list of keywords that will be used to filter the response. If not supplied, all album types will be returned. Valid values are: album; single; appears_on; compilation.
    # @param market     [String]  Optional. (synonym: country). An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. Supply this parameter to limit the response to one particular geographical market. If not supplied, results will be returned for all markets. Note if you do not provide this field, you are likely to get duplicate results per album, one for each market in which the album is available.
    # @return [Array<Album>]
    #
    # @example
    #           artist.albums
    #           artist.albums(album_type: 'single,compilation')
    #           artist.albums(limit: 50, country: 'US')
    def albums(limit: 20, offset: 0, **filters)
      url = "artists/#{@id}/albums?limit=#{limit}&offset=#{offset}"
      filters.each do |filter_name, filter_value|
        url << "&#{filter_name}=#{filter_value}"
      end

      json = RSpotify.get(url)
      json['items'].map { |i| Album.new i }
    end

    # Returns array of similar artists. Similarity is based on analysis of the Spotify community’s {http://news.spotify.com/se/2010/02/03/related-artists listening history}.
    #
    # @return [Array<Artist>]
    #
    # @example
    #           artist.name #=> "Arctic Monkeys"
    #           related_artists = artist.related_artists
    #
    #           related_artists.size       #=> 20
    #           related_artists.first.name #=> "Miles Kane"
    def related_artists
      return @related_artists unless @related_artists.nil?
      json = RSpotify.get("artists/#{@id}/related-artists")
      @related_artists = json['artists'].map { |a| Artist.new a }
    end

    # Returns artist's 10 top tracks by country.
    #
    # @param country [Symbol] An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}
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
