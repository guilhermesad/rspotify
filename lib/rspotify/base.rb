module RSpotify

  class Base

    def self.find(id, type)
      pluralized_type = "#{type}s"
      type_class = eval type.capitalize

      json = RSpotify.get "#{pluralized_type}/#{id}"
      type_class.new json
    end

    def self.search(query, type, limit = 20, offset = 0)
      pluralized_type = "#{type}s"
      type_class = eval type.capitalize

      json = RSpotify.get 'search',
        params: {
          q: query,
          type: type,
          limit: limit,
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

    def complete_object!
      pluralized_type = "#{type}s"
      initialize RSpotify.get("#{pluralized_type}/#{@id}")
    end

    def method_missing(method_name, *args)
      attr = "@#{method_name}".to_sym
      super unless instance_variables.include? attr 
      attr_value = instance_variable_get attr 
      return attr_value unless attr_value.nil?
      complete_object!
      instance_variable_get attr 
    end

    def respond_to?(method_name)
      attr = "@#{method_name}".to_sym
      return true if instance_variables.include? attr
      super
    end

  end
end
