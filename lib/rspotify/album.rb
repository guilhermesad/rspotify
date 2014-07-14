module RSpotify

  # @attr [String]        album_type             The type of the album (album, single, compilation)
  # @attr [Array<Artist>] artists                The artists of the album
  # @attr [Array<String>] available_markets      The markets in which the album is available. See {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country codes}
  # @attr [Hash]          external_ids           Known external IDs for the album
  # @attr [Array<String>] genres                 A list of the genres used to classify the album. If not yet classified, the array is empty
  # @attr [Array<Hash>]   images                 The cover art for the album in various sizes, widest first
  # @attr [String]        name                   The name of the album
  # @attr [Integer]       popularity             The popularity of the album. The value will be between 0 and 100, with 100 being the most popular
  # @attr [String]        release_date           The date the album was first released, for example "1981-12-15". Depending on the precision, it might be shown as "1981" or "1981-12"
  # @attr [String]        release_date_precision The precision with which release_date value is known: "year", "month", or "day"
  # @attr [Array<Track>]  tracks                 The tracks of the album.
  class Album < Base

    # Returns Album object(s) with id(s) provided
    #
    # @param ids [String, Array] Maximum: 20 IDs
    # @return [Album, Array<Album>]
    #
    # @example
    #           album = RSpotify::Album.find('41vPD50kQ7JeamkxQW7Vuy')
    #           album.class #=> RSpotify::Album
    #           album.name  #=> "AM"
    #           
    #           ids = %w(41vPD50kQ7JeamkxQW7Vuy 4jKGRliQXa5VwxKOsiCbfL)
    #           albums = RSpotify::Album.find(ids)
    #           albums.class       #=> Array
    #           albums.first.class #=> RSpotify::Album
    def self.find(ids)
      super(ids, 'album')
    end

    # Returns array of Album objects matching the query, ordered by popularity
    #
    # @param query  [String]  The search query's keywords. See the q description in {https://developer.spotify.com/web-api/search-item here} for details.
    # @param limit  [Integer] Maximum number of albums to return. Minimum: 1. Maximum: 50. Default: 20.
    # @param offset [Integer] The index of the first album to return. Use with limit to get the next set of albums. Default: 0.
    # @return [Array<Album>]
    #
    # @example
    #           albums = RSpotify::Album.search('AM')
    #           albums.size        #=> 20
    #           albums.first.class #=> RSpotify::Album
    #           albums.first.name  #=> "AM"
    #
    #           albums = RSpotify::Base.search('AM', limit: 10)
    #           albums.size #=> 10
    def self.search(query, limit: 20, offset: 0)
      super(query, 'album', limit: limit, offset: offset)
    end

    def initialize(options = {})
      @album_type             = options['album_type']
      @available_markets      = options['available_markets']
      @external_ids           = options['external_ids']
      @genres                 = options['genres']
      @images                 = options['images']
      @name                   = options['name']
      @popularity             = options['popularity']
      @release_date           = options['release_date']
      @release_date_precision = options['release_date_precision']

      @artists = if options['artists']
        options['artists'].map { |a| Artist.new a }
      end

      @tracks = if options['tracks'] && options['tracks']['items']
        options['tracks']['items'].map { |t| Track.new t }
      end

      super(options)
    end
  end
end
