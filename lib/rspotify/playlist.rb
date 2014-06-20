module RSpotify

  class Playlist < Base

    attr_accessor :collaborative, :description, :followers,
                  :images, :name, :owner, :public, :tracks

    def self.find(user_id, id)
      json = RSpotify.auth_get("users/#{user_id}/playlists/#{id}")
      Playlist.new json
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

      if options['tracks']
        tracks = options['tracks']['items']
        @tracks = tracks.map { |t| Track.new t['track'] }
      end

      super(options)
    end

  end
end
