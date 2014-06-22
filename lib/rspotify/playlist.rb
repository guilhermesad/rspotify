module RSpotify

  class Playlist < Base

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
      @public        = options['public']

      if options['owner']
        @owner = User.new options['owner']
      end

      if options['tracks'] && options['tracks']['items']
        tracks = options['tracks']['items']
        @tracks = tracks.map { |t| Track.new t['track'] }
      end

      super(options)
    end

    def complete_object!
      initialize RSpotify.auth_get("users/#{@owner.id}/playlists/#{@id}")
    end

  end
end
