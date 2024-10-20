module RSpotify

    # @attr [Array<AudioAnalysisBar>] bars           Array identified of bar objects
    # @attr [Array<AudioAnalysisBeat>] beats         Array identified of beat objects
    # @attr [Array<AudioAnalysisSection>] sections   Array identified of section objects
    # @attr [Array<AudioAnalysisSegment>] segments   Array identified of segments objects
    # @attr [Array<AudioAnalysisTatum>] tatums       Array identified of tatum objects
    # @attr [AudioAnalysisMeta] meta                 Metadata for the analysis result
    # @attr [AudioAnalysisTrack] track               General analysis data for the track
    class AudioAnalysis < Base
  
      # Retrieves AudioAnalysis object for the track id provided
      #
      # @param id [String] A single track id
      # @return [AudioAnalysis]
      #
      # @example
      #           audio_analysis = RSpotify::AudioAnalysis.find('1zHlj4dQ8ZAtrayhuDDmkY')
      def self.find(id)
          url = "audio-analysis/#{id}"
          response = RSpotify.get(url)
          return response if RSpotify.raw_response
  
          AudioAnalysis.new response
      end
  
      def initialize(options = {})

        @bars = if options['bars']
            options['bars'].map { |b| AudioAnalysisBar.new b }
        end
    
        @beats = if options['beats']
            options['beats'].map { |b| AudioAnalysisBeat.new b }
        end

        @meta = if options['meta']
            AudioAnalysisMeta.new options['meta']
        end

        @sections = if options['sections']
            options['sections'].map { |s| AudioAnalysisSection.new s }
        end

        @segments = if options['segments']
            options['segments'].map { |s| AudioAnalysisSegment.new s }
        end

        @tatums = if options['tatums']
            options['tatums'].map { |t| AudioAnalysisTatum.new t }
        end

        @track = if options['track']
            AudioAnalysisTrack.new options['track']
        end
        
        super(options)
    end
  
      # Spotify does not support search for audio features
      def self.search(*)
        warn 'Spotify API does not support search for audio analysis'
        false
      end
  
    end
end