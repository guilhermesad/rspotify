module RSpotify

  class Album < Base

    # Returns Album object(s) with id(s) provided
    #
    # @param ids [String, Array]
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
    # @param query [String]
    # @param limit [Integer]
    # @param offset [Integer]
    # @return [Array<Album>]
    #
    # @example
    #           albums = RSpotify::Album.search('AM')
    #           albums.size        #=> 20
    #           albums.first.class #=> RSpotify::Album
    #           albums.first.name  #=> "AM"
    #
    #           albums = RSpotify::Base.search('AM', 10)
    #           albums.size #=> 10
    def self.search(query, limit = 20, offset = 0)
      super(query, 'album', limit, offset)
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
