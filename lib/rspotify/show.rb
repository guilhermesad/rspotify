module RSpotify

  # @attr [Array<String>] available_markets   A list of the countries in which the show can be played, identified by their ISO 3166-1 alpha-2 code.
  # @attr [Array<Hash>]   copyrights          The copyright statements of the show.
  # @attr [String]        description         A description of the show. HTML tags are stripped away from this field, use html_description field in case HTML tags are needed.
  # @attr [Boolean]       explicit            Whether or not the show has explicit content (true = yes it does; false = no it does not OR unknown).
  # @attr [String]        html_description    A description of the show. This field may contain HTML tags.
  # @attr [Array<Hash>]   images              The cover art for the show in various sizes, widest first.
  # @attr [Boolean]       is_externally_hosted    True if all of the show’s episodes are hosted outside of Spotify’s CDN. This field might be null in some cases.
  # @attr [Array<String>] languages           A list of the languages used in the show, identified by their ISO 639 code.
  # @attr [String]        media_type          The media type of the show.
  # @attr [String]        name                The name of the show.
  # @attr [String]        publisher           The publisher of the show.
class Show < Base

    # Returns Show object(s) with id(s) provided
    #
    # @param id [String, Array] Maximum: 50 IDs
    # @param market [String] An {https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}.
    # @return [Show, Array<Show>]
    #
    # @example
    #           show = RSpotify::Show.find('3Z6JdCS2d0eFEpXHKI6WqH')
    #           show.class #=> RSpotify::Show
    #           show.name  #=> "Consider This from NPR"
    def self.find(ids, market: nil )
      super(ids, 'show', market: market)
    end
    
    # Returns array of Show objects matching the query. It's also possible to find the total number of search results for the query
    #
    # @param query  [String]  The search query's keywords. See the q description in {https://developer.spotify.com/web-api/search-item here} for details.
    # @param limit  [Integer] Maximum number of shows to return. Maximum: 50. Default: 20.
    # @param offset [Integer] The index of the first show to return. Use with limit to get the next set of shows. Default: 0.
    # @param market [String] An {https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}.
    # @return [Array<Show>]
    #
    # @example
    #           shows = RSpotify::Show.search('NPR')
    #           shows = RSpotify::Show.search('NPR', market: 'US', limit: 10)
    #
    #           RSpotify::Show.search('NPR').total #=> 357
    def self.search(query, limit: 20, offset: 0, market: nil)
      super(query, 'show', limit: limit, offset: offset, market: market)
    end

    def initialize(options = {})
      @available_markets = options['available_markets']
      @copyrights        = options['copyrights']
      @description       = options['description']
      @explicit          = options['explicit']
      @html_description  = options['html_description']
      @images            = options['images']
      @is_externally_hosted = options['is_externally_hosted']
      @languages         = options['languages']
      @media_type        = options['media_type']
      @name              = options['name']
      @publisher         = options['publisher']

      episodes = options['episodes']['items'] if options['episodes']

      @episodes_cache = if episodes
        episodes.map { |e| Episode.new e }
      end

      super(options)
    end

    # Returns array of episodes from the show
    #
    # @param limit  [Integer] Maximum number of episodes to return. Maximum: 50. Default: 20.
    # @param offset [Integer] The index of the first track to return. Use with limit to get the next set of objects. Default: 0.
    # @param market [String]  An {https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}.
    # @return [Array<Episode>]
    #
    # @example
    #           show = RSpotify::Show.find('3Z6JdCS2d0eFEpXHKI6WqH')
    #           show.episodes.first.name #=> "Colin Powell's Complicated Legacy"
    def episodes(limit: 20, offset: 0, market: nil )
      last_episode = offset + limit - 1
      if @episodes_cache && last_episode < 20 && !RSpotify.raw_response
        return @episodes_cache[offset..last_episode]
      end

      url = "#{@href}/episodes?limit=#{limit}&offset=#{offset}"
      url << "&market=#{market}" if market

      response = RSpotify.get url

      json = RSpotify.raw_response ? JSON.parse(response) : response
      episodes = json['items']

      episodes.map! { |e| Episode.new e }
      @episodes_cache = episodes if limit == 20 && offset == 0
      return response if RSpotify.raw_response
      episodes
    end

  end
end
