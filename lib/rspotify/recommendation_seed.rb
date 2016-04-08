module RSpotify

  # @attr [Integer] after_filtering_size The number of tracks available after min_* and max_* filters have been applied.
  # @attr [Integer] after_relinking_size The number of tracks available after relinking for regional availability.
  # @attr [Integer] initial_pool_size    The number of recommended tracks available for this seed.
  class RecommendationSeed < Base
    
    def initialize(options = {})
      @after_filtering_size = options['afterFilteringSize']
      @after_relinking_size = options['afterRelinkingSize']
      @initial_pool_size    = options['initialPoolSize']

      super(options)
    end

  end

end
