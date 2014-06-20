module RSpotify

  class Playlist < Base

    attr_accessor :collaborative, :description, :followers,
                  :images, :name, :owner, :public, :tracks

    def self.find(user_id, id)
      #TODO
    end

    def self.search
      #TODO
    end

    def initialize(options = {})
      @collaborative = options['collaborative']
      @description   = options['description']
      @followers     = options['followers']
      @images        = options['images']
      @name          = options['name']
      @owner         = options['owner']
      @public        = options['public']
      @tracks        = options['tracks']

      super(options)
    end

  end
end
