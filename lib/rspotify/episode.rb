module RSpotify

  # @attr [String]        audio_preview_url    A URL to a 30 second preview (MP3 format) of the episode. null if not available.
  # @attr [String]        description          A description of the episode. HTML tags are stripped away from this field, use html_description field in case HTML tags are needed.
  # @attr [Integer]       duration_ms          The episode length in milliseconds.
  # @attr [Boolean]       explicit             Whether or not the episode has explicit content (true = yes it does; false = no it does not OR unknown).
  # @attr [String]        href                 A link to the Web API endpoint providing full details of the episode.  
  # @attr [String]        html_description     A description of the episode. This field may contain HTML tags.  
  # @attr [Array<Hash>]   images               The cover art for the episode in various sizes, widest first.
  # @attr [Boolean]       is_externally_hosted True if the episode is hosted outside of Spotify’s CDN.
  # @attr [Boolean]       is_playable          True if the episode is playable in the given market. Otherwise false.
  # @attr [String]        language             The language used in the episode, identified by a ISO 639 code. This field is deprecated and might be removed in the future. Please use the languages field instead.
  # @attr [Array<String>] languages            A list of the languages used in the episode, identified by their ISO 639-1 code.
  # @attr [String]        name                 The name of the episode.
  # @attr [String]        release_date         The date the episode was first released, for example "1981-12-15". Depending on the precision, it might be shown as "1981" or "1981-12".
  # @attr [String]        release_date_precision         The precision with which release_date value is known.
  # @attr [Hash]          restrictions         Included in the response when a content restriction is applied.
  # @attr [Hash]          resume_point         The user’s most recent position in the episode. Set if the supplied access token is a user token and has the scope ‘user-read-playback-position’.
  class Episode < Base

    # Returns Episode object(s) with id(s) provided
    #
    # @param ids [String, Array] Maximum: 50 IDs
    # @param market [String] Optional. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}.
    # @return [Episode, Array<Episode>]
    #
    # @example
    #           episode = RSpotify::Episode.find('512ojhOuo1ktJprKbVcKyQ')
    #           episode.class #=> RSpotify::Episode
    #           episode.name  #=> "Do I Wanna Know?"
    #           
    #           ids = %w(512ojhOuo1ktJprKbVcKyQ 15tHEpY9pwbKC0QjpYCRB1)
    #           episodes = RSpotify::Base.find(ids, 'episode')
    #           episodes.class       #=> Array
    #           episodes.first.class #=> RSpotify::Episode
    def self.find(ids, market: nil)
      super(ids, 'episode', market: market)
    end

    # Returns array of Episode objects matching the query. It's also possible to find the total number of search results for the query
    #
    # @param query  [String]       The search query's keywords. For details access {https://developer.spotify.com/web-api/search-item here} and look for the q parameter description.
    # @param limit  [Integer]      Maximum number of episodes to return. Maximum: 50. Default: 20.
    # @param offset [Integer]      The index of the first episode to return. Use with limit to get the next set of episodes. Default: 0.
    # @param market [String, Hash] Optional. An {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code} or the hash { from: user }, where user is a RSpotify user authenticated using OAuth with scope *user-read-private*. This will take the user's country as the market value. For details access {https://developer.spotify.com/web-api/search-item here} and look for the market parameter description.
    # @return [Array<Episode>]
    #
    # @example
    #           episodes = RSpotify::Episode.search('Vetenskapsradion Historia')
    #           episodes = RSpotify::Episode.search('Vetenskapsradion Historia', limit: 10, market: 'US')
    #           episodes = RSpotify::Episode.search('Vetenskapsradion Historia', market: { from: user })
    #
    #           RSpotify::Episode.search('Vetenskapsradion Historia').total #=> 711
    def self.search(query, limit: 20, offset: 0, market: nil )
      super(query, 'episode', limit: limit, offset: offset, market: market)
    end

    def initialize(options = {})
      @audio_preview_url = options['audio_preview_url']
      @description       = options['description']
      @duration_ms       = options['duration_ms']
      @explicit          = options['explicit']
      @href              = options['href']
      @html_description  = options['html_description']
      @images            = options['images']
      @is_externally_hosted = options['is_externally_hosted']
      @is_playable       = options['is_playable']
      @language          = options['language']
      @languages         = options['languages']
      @name              = options['name']
      @release_date      = options['release_date']
      @release_date_precision = options['release_date_precision']
      @restrictions      = options['restrictions'] || {}
      @resume_point      = options['resume_point'] || {}
      @uri               = options['uri']

      @show = if options['show']
        Show.new options['show']
      end

      super(options)
    end
  end
end
