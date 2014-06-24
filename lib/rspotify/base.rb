module RSpotify

  class Base

    # Return RSpotify object(s) with id(s) and type provided
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
    #           ids= %w(2UzMpPKPhbcC8RbsmuURAZ 7Jzsc04YpkRwB1zeyM39wE)
    #           tracks = RSpotify::Base.find(ids, 'track')
    #           tracks.class       #=> Array
    #           tracks.first.class #=> RSpotify::Track
    def self.find(ids, type)
      case ids.class.to_s
      when 'Array'
        if type == 'user'
          warn 'Spotify API does not support finding several users simultaneously'
          return false
        end
        find_many(ids, type)
      when 'String'
        id = ids
        find_one(id, type)
      end
    end

    # Return RSpotify object with id and type provided (Specialization of Base::find)
    #
    # @param id [String]
    # @param type [String]
    # @return [Album, Artist, Track, User]
    #
    # @example
    #           user = RSpotify::Base.find_one('wizzler', 'user')
    #           user.class #=> RSpotify::User
    #           user.id    #=> "wizzler"
    #
    #           track = RSpotify::Base.find_one('2UzMpPKPhbcC8RbsmuURAZ', 'track')
    #           track.class #=> RSpotify::Track
    #           track.id    #=> "2UzMpPKPhbcC8RbsmuURAZ"
    def self.find_one(id, type)
      pluralized_type = "#{type}s"
      type_class = RSpotify.const_get(type.capitalize)

      path = "#{pluralized_type}/#{id}"
      json = RSpotify.get path
      type_class.new json
    end

    # Return RSpotify objects with ids and type provided (Specialization of Base::find)
    #
    # @param ids [Array]
    # @param type [String]
    # @return [Array<Album>, Array<Artist>, Array<Track>]
    #
    # @example
    #           ids= %w(2UzMpPKPhbcC8RbsmuURAZ 7Jzsc04YpkRwB1zeyM39wE)
    #           tracks = RSpotify::Base.find(ids, 'track')
    #           tracks.class       #=> Array
    #           tracks.first.class #=> RSpotify::Track
    def self.find_many(ids, type)
      pluralized_type = "#{type}s"
      type_class = RSpotify.const_get(type.capitalize)

      path = "#{pluralized_type}?ids=#{ids.join ','}"
      json = RSpotify.get path
      json[pluralized_type].map { |t| type_class.new t }
    end

    def self.search(query, type, limit = 20, offset = 0)
      pluralized_type = "#{type}s"
      type_class = RSpotify.const_get(type.capitalize)

      json = RSpotify.get 'search',
        params: {
          q:      query,
          type:   type,
          limit:  limit,
          offset: offset
        }

      items = json[pluralized_type]['items']
      items.map { |item| type_class.new item }
    end

    def initialize(options = {})
      @external_urls = options['external_urls']
      @href          = options['href']
      @id            = options['id']
      @type          = options['type']
      @uri           = options['uri']
    end

    def complete!
      pluralized_type = "#{type}s"
      initialize RSpotify.get("#{pluralized_type}/#{@id}")
    end

    def method_missing(method_name, *args)
      attr = "@#{method_name}".to_sym
      super unless instance_variables.include? attr 

      attr_value = instance_variable_get attr 
      return attr_value unless attr_value.nil?

      complete!
      instance_variable_get attr 
    end

    def respond_to?(method_name)
      attr = "@#{method_name}".to_sym
      return true if instance_variables.include? attr
      super
    end
  end
end
