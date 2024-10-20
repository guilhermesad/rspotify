module RSpotify
    # @attr [Float] confidence          The confidence, from 0.0 to 1.0, of the reliability of the interval
    # @attr [Float] duration            The duration (in seconds) of the time interval
    # @attr [Float] loudness_end        The offset loudness of the segment in decibels (dB)
    # @attr [Float] loudness_max        The peak loudness of the segment in decibels (dB)
    # @attr [Float] loudness_max_time   The segment-relative offset of the segment peak loudness in seconds
    # @attr [Float] loudness_start      The onset loudness of the segment in decibels (dB)
    # @attr [Array<Float>] pitches      Pitch content is given by a “chroma” vector, corresponding to the 12 pitch classes C, C#, D to B, with values ranging from 0 to 1 that describe the relative dominance of every pitch in the chromatic scale
    # @attr [Float] start               The starting point (in seconds) of the time interval
    # @attr [Arrat<Float>] timbre       The shape of a segment’s spectro-temporal surface
    class AudioAnalysisSegment
      attr_reader :confidence, :duration, :loudness_start, :loudness_max, :loudness_max_time, :loudness_end, :pitches, :start, :timbre
  
      def initialize(options = {})
        @confidence = options['confidence']
        @duration = options['duration']
        @loudness_end = options['loudness_end']
        @loudness_max = options['loudness_max']
        @loudness_max_time = options['loudness_max_time']
        @loudness_start = options['loudness_start']
        @pitches = options['pitches']
        @start = options['start']
        @timbre = options['timbre']
      end
    end
  end