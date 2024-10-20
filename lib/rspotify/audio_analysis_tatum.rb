module RSpotify
  # @attr [Float] confidence    The confidence, from 0.0 to 1.0, of the reliability of the interval
  # @attr [Float] duration      The duration (in seconds) of the time interval
  # @attr [Float] start         The starting point (in seconds) of the time interval
  class AudioAnalysisTatum
    attr_reader :confidence, :duration, :start

    def initialize(options = {})
      @confidence = options['confidence']
      @duration = options['duration']
      @start = options['start']
    end
  end
end