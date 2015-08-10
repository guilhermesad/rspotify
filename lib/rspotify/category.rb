module RSpotify

  # @attr [NilClass] external_urls Inexistent for Category.
  # @attr [String]   href          A link to the Spotify Web API endpoint returning full details of the category.
  # @attr [Array]    icons         An array of image objects. The category icons, in various sizes.
  # @attr [String]   id            The {https://developer.spotify.com/web-api/user-guide/#spotify-uris-and-ids Spotify ID} of the category
  # @attr [String]   name          The name of the category.
  # @attr [NilClass] type          Inexistent for Category.
  # @attr [NilClass] uri           Inexistent for Category.
  class Category < Base

    # Returns Category object with id provided
    #
    # @param id      [String] The {https://developer.spotify.com/web-api/user-guide/#spotify-uris-and-ids Spotify ID} of the category
    # @param country [String] Optional. A country: an {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. Provide this parameter to ensure that the category exists for a particular country.
    # @param locale  [String] Optional. The desired language, consisting of a lowercase {http://en.wikipedia.org/wiki/ISO_639 ISO 639 language code} and an uppercase {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}, joined by an underscore. For details access {https://developer.spotify.com/web-api/get-category/ here} and look for the locale parameter description.
    # @return [Category]
    #
    # @example
    #           category = RSpotify::Category.find('party')
    #           category = RSpotify::Category.find('party', country: 'US')
    #           category = RSpotify::Category.find('party', locale: 'es_MX')
    def self.find(id, **options)
      url = "browse/categories/#{id}"
      url << '?' if options.any?

      options.each_with_index do |option, index|
        url << "#{option[0]}=#{option[1]}"
        url << '&' unless index == options.size-1
      end

      response = RSpotify.get(url)
      return response if RSpotify.raw_response
      Category.new response
    end

    # Get a list of categories used to tag items in Spotify
    #
    # @param limit  [Integer] Optional. Maximum number of categories to return. Maximum: 50. Default: 20.
    # @param offset [Integer] Optional. The index of the first category to return. Use with limit to get the next set of categories. Default: 0.
    # @param country [String] Optional. A country: an {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. Provide this parameter if you want to narrow the list of returned categories to those relevant to a particular country. If omitted, the returned categories will be globally relevant.
    # @param locale  [String] Optional. The desired language, consisting of a lowercase {http://en.wikipedia.org/wiki/ISO_639 ISO 639 language code} and an uppercase {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}, joined by an underscore. For details access {https://developer.spotify.com/web-api/get-category/ here} and look for the locale parameter description.
    # @return [Array<Category>]
    #
    # @example
    #           categories = RSpotify::Category.list
    #           categories = RSpotify::Category.list(country: 'US')
    #           categories = RSpotify::Category.list(locale: 'es_MX', limit: 10)
    def self.list(limit: 20, offset: 0, **options)
      url = "browse/categories?limit=#{limit}&offset=#{offset}"
      options.each do |option, value|
        url << "&#{option}=#{value}"
      end

      response = RSpotify.get(url)
      return response if RSpotify.raw_response
      response['categories']['items'].map { |i| Category.new i }
    end

    # Spotify does not support search for categories.
    def self.search(*)
      warn 'Spotify API does not support search for categories'
      false
    end

    def initialize(options = {})
      @icons = options['icons']
      @name  = options['name']

      super(options)
    end

    # See {Base#complete!}
    def complete!
      initialize RSpotify.get("browse/categories/#{@id}")
    end

    # Get a list of Spotify playlists tagged with a particular category.
    #
    # @param limit  [Integer] Maximum number of playlists to return. Maximum: 50. Default: 20.
    # @param offset [Integer] The index of the first playlist to return. Use with limit to get the next set of playlists. Default: 0.
    # @param country [String] Optional. A country: an {http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 ISO 3166-1 alpha-2 country code}. Provide this parameter if you want to narrow the list of returned playlists to those relevant to a particular country. If omitted, the returned playlists will be globally relevant.
    # @return [Array<Playlist>]
    #
    # @example
    #           playlists = category.playlists
    #           playlists = category.playlists(country: 'BR')
    #           playlists = category.playlists(limit: 10, offset: 20)
    def playlists(limit: 20, offset: 0, **options)
      url = "browse/categories/#{@id}/playlists"\
            "?limit=#{limit}&offset=#{offset}"

      options.each do |option, value|
        url << "&#{option}=#{value}"
      end

      response = RSpotify.get(url)
      return response if RSpotify.raw_response
      response['playlists']['items'].map { |i| Playlist.new i }
    end
  end
end
