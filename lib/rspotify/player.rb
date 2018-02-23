module RSpotify
  class Player < Base

    def initialize(user, options = {})
      @user = user

      @repeat_state  = options['repeat_state']
      @shuffle_state = options['shuffle_state']
      @progress      = options['progress_ms']
      @is_playing    = options['is_playing']

      @track = if options['track']
                 Track.new options['track']
               end

      @device = if options['device']
                  Device.new options['device']
                end
    end

    def playing?
      is_playing
    end

    # Allow user to play a specific context(albums, artists & playlists).
    # If `device_id` is not passed, the currently active spotify app will be triggered
    #
    # @example
    #           player = user.player
    #           player.play_context(nil,"spotify:album:1Je1IMUlBXcx1Fz0WE7oPT")
    def play_context(device_id=nil, uri)
      params = {"context_uri": uri}
      play(device_id, params)
    end

    # Allow user to play a list of tracks.
    # If `device_id` is not passed, the currently active spotify app will be triggered
    #
    # @example
    #           player = user.player
    #           tracks_uris = ["spotify:track:4iV5W9uYEdYUVa79Axb7Rh", "spotify:track:1301WleyT98MSxVHPZCA6M"]
    #           player.play_tracks(nil, tracks_uris)
    def play_tracks(device_id=nil, uris)
      params = {"uris": uris}
      play(device_id, params)
    end

    # Allow browser to trigger playback in the user's currently active spotify app.
     # If `device_id` is not passed, the currently active spotify app will be triggered
    #
    # @example
    #           player = user.player
    #           player.play_track(nil, "spotify:track:4iV5W9uYEdYUVa79Axb7Rh")
    #           # User must be a premium subscriber for this feature to work.
    def play_track(device_id=nil, uri)
      params = {"uris": [uri]}
      play(device_id, params)
    end

    # Play the user's currently active player or specific device
    # If `device_id` is not passed, the currently active spotify app will be triggered
    #
    # @example
    #           player = user.player
    #           player.play
    def play(device_id = nil, params = {})
      url = "me/player/play"
      url = device_id.nil? ? url : url+"?device_id=#{device_id}"

      User.oauth_put(@user.id, url, params.to_json)
    end

    # Pause the user's currently active player
    #
    # @example
    #           player = user.player
    #           player.pause
    def pause
      url = 'me/player/pause'
      User.oauth_put(@user.id, url, {})
    end

    # Update the user's currently active player volume
    #
    # @example
    #           player = user.player
    #           player.volume(50)
    def volume(percent)
      url = "me/player/volume?volume_percent=#{percent}"
      User.oauth_put(@user.id, url, {})
    end

    def currently_playing
      url = "me/player/currently-playing"
      response = RSpotify.resolve_auth_request(@user.id, url)
      return response if RSpotify.raw_response
      Track.new response["item"]
    end
  end
end
