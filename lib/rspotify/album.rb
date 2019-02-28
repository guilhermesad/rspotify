module RSpotify

  # @attr [String]        album_type             The type of the album (album, single, compilation)
  # @attr [Array<Artist>] artists                The artists of the album
  # @attr [Array<String>] available_markets      The markets in which the album is available. See {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country codes}
  # @attr [Array<Hash>]   copyrights             The copyright statements of the album
  # @attr [Hash]          external_ids           Known external IDs for the album
  # @attr [Array<String>] genres                 A list of the genres used to classify the album. If not yet classified, the array is empty
  # @attr [Array<Hash>]   images                 The cover art for the album in various sizes, widest first
  # @attr [String]        label                  The label for the album
  # @attr [String]        name                   The name of the album
  # @attr [Integer]       popularity             The popularity of the album. The value will be between 0 and 100, with 100 being the most popular
  # @attr [String]        release_date           The date the album was first released, for example "1981-12-15". Depending on the precision, it might be shown as "1981" or "1981-12"
  # @attr [String]        release_date_precision The precision with which release_date value is known: "year", "month", or "day"
  # @attr [Integer]       total_tracks           The total number of tracks in the album
  class Album < Base

    # Returns Album object(s) with id(s) provided
    #
    # @param ids [String, Array] Maximum: 20 IDs
    # @param market [String] Optional. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}.
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
    def self.find(ids, market: nil)
      super(ids, 'album', market: market)
    end

    # Get a list of new album releases featured in Spotify (shown, for example, on a Spotify player’s “Browse” tab).
    #
    # @param limit   [Integer] Maximum number of albums to return. Maximum: 50. Default: 20.
    # @param offset  [Integer] The index of the first album to return. Use with limit to get the next set of albums. Default: 0.
    # @param country [String]  Optional. A country: an {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. Provide this parameter if you want the list of returned albums to be relevant to a particular country. If omitted, the returned albums will be relevant to all countries.
    # @return [Array<Album>]
    #
    # @example
    #           albums = RSpotify::Album.new_releases
    #           albums = RSpotify::Album.new_releases(country: 'US', limit: 10)
    def self.new_releases(limit: 20, offset: 0, country: nil)
      url = "browse/new-releases?limit=#{limit}&offset=#{offset}"
      url << "&country=#{country}" if country
      response = RSpotify.get(url)

      return response if RSpotify.raw_response
      response['albums']['items'].map { |i| Album.new i }
    end

    # Returns array of Album objects matching the query, ordered by popularity. It's also possible to find the total number of search results for the query
    #
    # @param query  [String]       The search query's keywords. For details access {https://developer.spotify.com/web-api/search-item here} and look for the q parameter description.
    # @param limit  [Integer]      Maximum number of albums to return. Maximum: 50. Default: 20.
    # @param offset [Integer]      The index of the first album to return. Use with limit to get the next set of albums. Default: 0.
    # @param market [String, Hash] Optional. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code} or the hash { from: user }, where user is a RSpotify user authenticated using OAuth with scope *user-read-private*. This will take the user's country as the market value. For details access {https://developer.spotify.com/web-api/search-item here} and look for the market parameter description.
    # @return [Array<Album>]
    #
    # @example
    #           albums = RSpotify::Album.search('AM')
    #           albums = RSpotify::Album.search('AM', limit: 10, market: 'US')
    #           albums = RSpotify::Album.search('AM', market: { from: user })
    #
    #           RSpotify::Album.search('AM').total #=> 9374
    def self.search(query, limit: 20, offset: 0, market: nil)
      super(query, 'album', limit: limit, offset: offset, market: market)
    end

    def initialize(options = {})
      @album_type             = options['album_type']
      @available_markets      = options['available_markets']
      @copyrights             = options['copyrights']
      @external_ids           = options['external_ids']
      @genres                 = options['genres']
      @images                 = options['images']
      @label                  = options['label']
      @name                   = options['name']
      @popularity             = options['popularity']
      @release_date           = options['release_date']
      @release_date_precision = options['release_date_precision']

      @artists = if options['artists']
        options['artists'].map { |a| Artist.new a }
      end

      @tracks_cache, @total_tracks = if options['tracks'] && options['tracks']['items']
        [
          options['tracks']['items'].map { |i| Track.new i },
          options['tracks']['total']
        ]
      end

      super(options)
    end

    # Returns array of tracks from the album
    #
    # @param limit  [Integer] Maximum number of tracks to return. Maximum: 50. Default: 50.
    # @param offset [Integer] The index of the first track to return. Use with limit to get the next set of objects. Default: 0.
    # @param market [String] Optional. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. Default: nil.
    # @return [Array<Track>]
    #
    # @example
    #           album = RSpotify::Album.find('41vPD50kQ7JeamkxQW7Vuy')
    #           album.tracks.first.name #=> "Do I Wanna Know?"
    def tracks(limit: 50, offset: 0, market: nil)
      last_track = offset + limit - 1
      if @tracks_cache && last_track < 50 && !RSpotify.raw_response
        return @tracks_cache[offset..last_track]
      end

      url = "albums/#{@id}/tracks?limit=#{limit}&offset=#{offset}"
      url << "&market=#{market}" if market
      response = RSpotify.get(url)
      json = RSpotify.raw_response ? JSON.parse(response) : response

      tracks = json['items'].map { |i| Track.new i }
      @tracks_cache = tracks if limit == 50 && offset == 0
      return response if RSpotify.raw_response

      tracks
    end
  end
end
