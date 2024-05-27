module RSpotify

    # @attr [String] analyzer_version  The version of the Analyzer used to analyze this track
    # @attr [String] platform          The platform used to read the track's audio data
    # @attr [String] detailed_status   A detailed status code for this track. If analysis data is missing, this code may explain why
    # @attr [Integer] status_code      The return code of the analyzer process. 0 if successful, 1 if any errors occurred
    # @attr [Integer] timestamp        The Unix timestamp (in seconds) at which this track was analyzed
    # @attr [Float] analysis_time      The amount of time taken to analyze this track.
    # @attr [String] input_process     The method used to read the track's audio data
    class AudioAnalysisMeta
      attr_reader :analysis_time, :analyzer_version, :detailed_status, :input_process, :platform, :status_code, :timestamp 
  
      def initialize(options = {})
        @analysis_time    = options['analysis_time']
        @analyzer_version = options['analyzer_version']
        @detailed_status  = options['detailed_status']
        @input_process    = options['input_process']
        @platform         = options['platform']
        @status_code      = options['status_code']
        @timestamp        = options['timestamp']
      end
    end
  end