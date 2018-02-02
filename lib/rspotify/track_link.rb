module RSpotify

  # @attr [Hash]   external_urls Known external URLs for this playlist
  # @attr [String] href          A link to the Web API endpoint
  # @attr [String] id            The {https://developer.spotify.com/web-api/user-guide/#spotify-uris-and-ids Spotify ID} for the track
  # @attr [String] type          The object type: "track"
  # @attr [String] uri           The {https://developer.spotify.com/web-api/user-guide/#spotify-uris-and-ids Spotify URI} for the object
  class TrackLink
    attr_reader :external_urls, :href, :id, :type, :uri

    def initialize(options = {})
      @external_urls = options['external_urls']
      @href          = options['href']
      @id            = options['id']
      @type          = options['type']
      @uri           = options['uri']
    end
  end
end
