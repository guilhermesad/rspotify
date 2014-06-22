module RSpotify

  class User < Base

    def self.find(id)
      if id.is_a? Array
        warn 'Spotify API does not support finding several users simultaneously'
        return false
      end
      super(id, 'user')
    end

    def self.search
      #TODO
    end

    def initialize(options = {})
      super(options)
    end

    def playlists
      return @playlists unless @playlists.nil?
      playlists = RSpotify.auth_get("users/#{@id}/playlists")['items']
      @playlists = playlists.map { |p| Playlist.new p }
    end
  end
end
