module RSpotify

  class User < Base

    def self.find(id)
      super(id, 'user')
    end

    def self.search
      #TODO
    end

    def initialize(options = {})
      super(options)
    end

  end
end
