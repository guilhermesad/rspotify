module RSpotify
  # @attr [Array<String>]   available_markets	    A list of the countries in which the show can be played, identified by their ISO 3166-1 alpha-2 code.
  # @attr [Array<Hash>]     copyrights            The copyright statements of the show
  # @attr [String]          description           A description of the show.
  # @attr [Boolean]         explicit	            Whether or not the show has explicit content (true = yes it does; false = no it does not OR unknown).
  # @attr [Array<Hash>]     episodes              A list of the show’s episodes inside a paging object
  # @attr [Hash]            external_urls         Known external URLs for this show
  # @attr [String]          href                  A link to the Web API endpoint providing full details of the show
  # @attr [String]          id	                  The Spotify ID for the show
  # @attr [Array<Hash>]     images                The cover art for the show in various sizes, widest first
  # @attr [Boolean]         is_externally_hosted  True if all of the show’s episodes are hosted outside of Spotify’s CDN. This field might be null in some cases
  # @attr [Array<String>]   languages             A list of the languages used in the show, identified by their ISO 639 code.
  # @attr [String]          media_type            The media type of the show
  # @attr [String]          name                  The name of the show
  # @attr [String]          publisher             The publisher of the show
  # @attr [String]          type                  The object type: "show"
  # @attr [String]          uri	                  The Spotify URI for the show
  # @attr [Integer]         total_episodes        Total number of episodes in the show

  class Show < Base
    def initialize(options = {})
      @available_markets =    options['available_markets']
      @copyrights =           options['copyrights']
      @description =          options['description']
      @explicit =             options['explicit']
      @episodes =             options['episodes']
      @external_urls =        options['external_urls']
      @href =                 options['href']
      @id =                   options['id']
      @images =               options['images']
      @is_externally_hosted = options['is_externally_hosted']
      @languages =            options['languages']
      @media_type =           options['media_type']
      @name =                 options['name']
      @publisher =            options['publisher']
      @type =                 options['type']
      @uri =                  options['uri']
      @total_episodes =       options['total_episodes']

      super(options)
    end
  end
end
