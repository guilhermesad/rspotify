module RSpotify
    # @attr [Float] confidence                  The confidence, from 0.0 to 1.0, of the reliability of the interval
    # @attr [Float] duration                    The duration (in seconds) of the time interval
    # @attr [Float] key                         The estimated overall key of the section. The values in this field ranging from 0 to 11 mapping to pitches using standard Pitch Class notation (E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on). If no key was detected, the value is -1
    # @attr [Float] key_confidence              The confidence, from 0.0 to 1.0, of the reliability of the key. Songs with many key changes may correspond to low values in this field
    # @attr [Float] loudness                    The overall loudness of the section in decibels (dB)
    # @attr [Float] mode                        Indicates the modality (major or minor) of a section, the type of scale from which its melodic content is derived. This field will contain a 0 for "minor", a 1 for "major", or a -1 for no result
    # @attr [Float] mode_confidence             The confidence, from 0.0 to 1.0, of the reliability of the mode
    # @attr [Float] start                       The starting point (in seconds) of the time interval
    # @attr [Float] tempo                       The overall estimated tempo of the section in beats per minute (BPM)
    # @attr [Float] tempo_confidence            The confidence, from 0.0 to 1.0, of the reliability of the tempo
    # @attr [Float] time_signature              An estimated time signature. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure). The time signature ranges from 3 to 7 indicating time signatures of "3/4", to "7/4"
    # @attr [Float] time_signature_confidence   The confidence, from 0.0 to 1.0, of the reliability of the time_signature. Sections with time signature changes may correspond to low values in this field
    class AudioAnalysisSection
      attr_reader :confidence, :duration, :key, :key_confidence, :loudness, :mode, :mode_confidence, :start, :tempo, :tempo_confidence, :time_signature, :time_signature_confidence
  
      def initialize(options = {})
        @confidence = options['confidence']
        @duration = options['duration']
        @key = options['key']
        @key_confidence = options['key_confidence']
        @loudness = options['loudness']
        @mode = options['mode']
        @mode_confidence = options['mode_confidence']
        @start = options['start']
        @tempo = options['tempo']
        @tempo_confidence = options['tempo_confidence']
        @time_signature = options['time_signature']
        @time_signature_confidence = options['time_signature_confidence']
      end
    end
  end