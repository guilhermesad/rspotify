module RSpotify

  # @attr [Hash]   external_urls Known external URLs for object
  # @attr [String] href          A link to the Web API endpoint
  # @attr [String] id            The {https://developer.spotify.com/web-api/user-guide/#spotify-uris-and-ids Spotify ID} for the object
  # @attr [String] type          The object type (artist, album, etc.)
  # @attr [String] uri           The {https://developer.spotify.com/web-api/user-guide/#spotify-uris-and-ids Spotify URI} for the object
  class Base

    # Returns RSpotify object(s) with id(s) and type provided
    #
    # @param ids [String, Array]
    # @param type [String]
    # @return [Album, Artist, Track, User, Array<Album>, Array<Artist>, Array<Track>]
    #
    # @example
    #           user = RSpotify::Base.find('wizzler', 'user')
    #           user.class #=> RSpotify::User
    #           user.id    #=> "wizzler"
    #           
    #           ids = %w(2UzMpPKPhbcC8RbsmuURAZ 7Jzsc04YpkRwB1zeyM39wE)
    #           tracks = RSpotify::Base.find(ids, 'track')
    #           tracks.class       #=> Array
    #           tracks.first.class #=> RSpotify::Track
    def self.find(ids, type)
      case ids
      when Array
        if type == 'user'
          warn 'Spotify API does not support finding several users simultaneously'
          return false
        end
        limit = (type == 'album' ? 20 : 50)
        if ids.size > limit
          warn "Too many ids requested. Maximum: #{limit} for #{type}"
          return false
        end
        find_many(ids, type)
      when String
        id = ids
        find_one(id, type)
      end
    end

    def self.find_many(ids, type)
      type_class = RSpotify.const_get(type.capitalize)

      path = "#{type}s?ids=#{ids.join ','}"
      json = RSpotify.get path
      json["#{type}s"].map { |t| type_class.new t }
    end
    private_class_method :find_many

    def self.find_one(id, type)
      type_class = RSpotify.const_get(type.capitalize)

      path = "#{type}s/#{id}"
      json = RSpotify.get path
      type_class.new json
    end
    private_class_method :find_one

    # Returns array of RSpotify objects matching the query, ordered by popularity
    #
    # @param query  [String]  The search query's keywords. See the q description in {https://developer.spotify.com/web-api/search-item here} for details.
    # @param type   [String]  Valid types are: album, artist and track. Separate multiple types with commas.
    # @param limit  [Integer] Maximum number of objects to return. Minimum: 1. Maximum: 50. Default: 20.
    # @param offset [Integer] The index of the first object to return. Use with limit to get the next set of objects. Default: 0.
    # @return [Array<Base>]
    #
    # @example
    #           artists = RSpotify::Base.search('Arctic', 'artist')
    #           artists.size        #=> 20
    #           artists.first.class #=> RSpotify::Artist
    #           artists.first.name  #=> "Arctic Monkeys"
    #
    #           albums = RSpotify::Base.search('AM', 'album', limit: 10)
    #           albums.size #=> 10
    def self.search(query, types, limit: 20, offset: 0)
      if limit < 1 || limit > 50
        warn 'Limit must be between 1 and 50'
        return false
      end

      types.gsub!(/\s+/, '')

      json = RSpotify.get 'search',
        params: {
          q:      query,
          type:   types,
          limit:  limit,
          offset: offset
        }

      types.split(',').flat_map do |type|
        type_class = RSpotify.const_get(type.capitalize)
        json["#{type}s"]['items'].map { |item| type_class.new item }
      end
    end

    def initialize(options = {})
      @external_urls = options['external_urls']
      @href          = options['href']
      @id            = options['id']
      @type          = options['type']
      @uri           = options['uri']
    end

    # When an object is obtained undirectly, Spotify usually returns a simplified version of it.
    # This method updates it into a full object, with all attributes filled.
    # 
    # @note It is seldom necessary to use this method explicitly, since RSpotify takes care of it automatically when needed (see {#method_missing})
    #
    # @example
    #           track = artist.tracks.first
    #           track.instance_variable_get("@popularity") #=> nil
    #           track.complete!
    #           track.instance_variable_get("@popularity") #=> 62
    def complete!
      initialize RSpotify.get("#{type}s/#{@id}")
    end

    # Used internally to retrieve an object's instance variable. If instance
    # variable equals nil, calls {#complete!} on object and retrieve it again.
    #
    # @example
    #           user.id #=> "wizzler"
    #
    #           track = artist.tracks.first
    #           track.instance_variable_get("@popularity") #=> nil
    #           track.popularity #=> 62
    #           track.instance_variable_get("@popularity") #=> 62
    def method_missing(method_name, *args)
      attr = "@#{method_name}"
      super unless instance_variable_defined? attr

      attr_value = instance_variable_get attr
      return attr_value unless attr_value.nil?

      complete!
      instance_variable_get attr
    end

    # Overrides Object#respond_to? to also consider methods dynamically generated by {#method_missing}
    def respond_to?(method_name, include_private_methods = false)
      attr = "@#{method_name}"
      return true if instance_variable_defined? attr
      super
    end
  end
end
