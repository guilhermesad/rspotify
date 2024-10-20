module RSpotify
    # @attr [Integer] analysis_channels                  The number of channels used for analysis
    # @attr [Integer] analysis_sample_rate               The sample rate used to decode and analyze this track
    # @attr [Float] code_version                         A version number for the Echo Nest Musical Fingerprint format used in the codestring field
    # @attr [String] codestring                          An Echo Nest Musical Fingerprint (ENMFP) codestring for this track
    # @attr [Integer] duration                           Length of the track in seconds
    # @attr [Float] echoprint_version                    A version number for the EchoPrint format used in the echoprintstring field
    # @attr [Float] echoprintstring                      An EchoPrint codestring for this track
    # @attr [Float] end_of_fade_in                       The time, in seconds, at which the track's fade-in period ends. If the track has no fade-in, this will be 0.0
    # @attr [Integer] key                                The key the track is in. Integers map to pitches using standard Pitch Class notation
    # @attr [Float] key_confidence                       The confidence, from 0.0 to 1.0, of the reliability of the key
    # @attr [Float] loudness                             The overall loudness of a track in decibels (dB)
    # @attr [Integer] mode                               Mode indicates the modality (major or minor) of a track, Major is represented by 1 and minor is 0
    # @attr [Float] mode_confidence                      The confidence, from 0.0 to 1.0, of the reliability of the mode
    # @attr [Integer] num_samples                        The exact number of audio samples analyzed from this track
    # @attr [Integer] offset_seconds                     An offset to the start of the region of the track that was analyzed
    # @attr [Float] rhythm_version                       A version number for the Rhythmstring used in the rhythmstring
    # @attr [String] rhythmstring                        A Rhythmstring for this track. The format of this string is similar to the Synchstring
    # @attr [String] sample_md5                          This field will always contain an empty string
    # @attr [Float] start_of_fade_out                    The time, in seconds, at which the track's fade-out period starts. If the track has no fade-out, this should match the track's length
    # @attr [Float] synch_version                        A version number for the Synchstring used in the synchstring
    # @attr [String] synchstring                         A Synchstring for this track
    # @attr [Float] tempo                                The overall estimated tempo of a track in beats per minute (BPM)
    # @attr [Float] tempo_confidence                     The confidence, from 0.0 to 1.0, of the reliability of the tempo
    # @attr [Integer] time_signature                     An estimated time signature
    # @attr [Float] time_signature_confidence            The confidence, from 0.0 to 1.0, of the reliability of the tempo
    # @attr [Integer] window_seconds                     The length of the region of the track was analyzed, if a subset of the track was analyzed
    class AudioAnalysisTrack
      attr_reader :analysis_channels, :analysis_sample_rate, :code_version, :codestring, :duration, :echoprint_version, :echoprintstring, :end_of_fade_in, :key_confidence, :key, :loudness, :tempo, :mode_confidence, :mode, :num_samples, :offset_seconds, :rhythm_version, :rhythmstring, :sample_md5, :start_of_fade_out, :synch_version, :synchstring, :tempo_confidence, :time_signature_confidence, :time_signature, :window_seconds

  
      def initialize(options = {})
        @analysis_channels = options['analysis_channels']
        @analysis_sample_rate = options['analysis_sample_rate']
        @code_version = options['code_version']
        @codestring = options['codestring']
        @duration = options['duration']
        @echoprint_version = options['echoprint_version']
        @echoprintstring = options['echoprintstring']
        @end_of_fade_in = options['end_of_fade_in']
        @key = options['key']
        @key_confidence = options['key_confidence']
        @loudness = options['loudness']
        @mode = options['mode']
        @mode_confidence = options['mode_confidence']
        @num_samples = options['num_samples']
        @offset_seconds = options['offset_seconds']
        @rhythm_version = options['rhythm_version']
        @rhythmstring = options['rhythmstring']
        @sample_md5 = options['sample_md5']
        @start_of_fade_out = options['start_of_fade_out']
        @synch_version = options['synch_version']
        @synchstring = options['synchstring']
        @tempo = options['tempo']
        @tempo_confidence = options['tempo_confidence']
        @time_signature = options['time_signature']
        @time_signature_confidence = options['time_signature_confidence']
        @window_seconds = options['window_seconds']
      end
    end
  end

  