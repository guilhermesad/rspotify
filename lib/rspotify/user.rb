module RSpotify

  class User < Base

    # Returns User object with id provided
    #
    # @param ids [String]
    # @return [User]
    #
    # @example
    #           user = RSpotify::User.find('wizzler')
    #           user.class #=> RSpotify::User
    #           user.id    #=> "wizzler"
    def self.find(id)
      super(id, 'user')
    end

    # Spotify does not support search for users. Prints warning and returns false
    def self.search(*args)
      warn 'Spotify API does not support search for users'
      false
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
