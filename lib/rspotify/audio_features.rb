module RSpotify

  # @attr [Float]   acousticness      A confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic.
  # @attr [String]  analysis_url      An HTTP URL to access the full audio analysis of this track. This URL is cryptographically signed and configured to expire after roughly 10 minutes. Do not store these URLs for later use.
  # @attr [Float]   danceability      Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable.
  # @attr [Integer] duration_ms       The duration of the track in milliseconds.
  # @attr [Float]   energy            Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy.
  # @attr [Float]   instrumentalness  Predicts whether a track contains no vocals. "Ooh" and "aah" sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly "vocal". The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0.
  # @attr [Integer] key               The key the track is in. Integers map to pitches using standard {https://en.wikipedia.org/wiki/Pitch_class Pitch Class notation}. E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on.
  # @attr [Float]   liveness          Detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 provides strong likelihood that the track is live.
  # @attr [Float]   loudness          The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typical range between -60 and 0 db.
  # @attr [Integer] mode              Mode indicates the modality (major or minor) of a track, the type of scale from which its melodic content is derived. Major is represented by 1 and minor is 0.
  # @attr [Float]   speechiness       Speechiness detects the presence of spoken words in a track. The more exclusively speech-like the recording (e.g. talk show, audio book, poetry), the closer to 1.0 the attribute value. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks.
  # @attr [Float]   tempo             The overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration.
  # @attr [Integer] time_signature    An estimated overall time signature of a track. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure).
  # @attr [String]  track_href        A link to the Web API endpoint providing full details of the track.
  # @attr [Float]   valence           A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).
  class AudioFeatures < Base

    # Retrieves AudioFeatures object(s) for the track id(s) provided
    #
    # @param ids [String, Array] Either a single track id or a list track ids. Maximum: 100 IDs.
    # @return [AudioFeatures, Array<AudioFeatures>]
    #
    # @example
    #           audio_features = RSpotify::AudioFeatures.find('1zHlj4dQ8ZAtrayhuDDmkY')
    #           audio_features = RSpotify::AudioFeatures.find(['1zHlj4dQ8ZAtrayhuDDmkY', '7ouMYWpwJ422jRcDASZB7P', '4VqPOruhp5EdPBeR92t6lQ'])
    def self.find(ids)
      case ids
      when Array
        url = "audio-features?ids=#{ids.join(',')}"
        response = RSpotify.get(url)
        return response if RSpotify.raw_response

        response['audio_features'].map { |i| i.nil? ? nil : AudioFeatures.new(i) }
      when String
        url = "audio-features/#{ids}"
        response = RSpotify.get(url)
        return response if RSpotify.raw_response

        AudioFeatures.new response
      end
    end

    def initialize(options = {})
      @acousticness = options['acousticness']
      @analysis_url = options['analysis_url']
      @danceability = options['danceability']
      @duration_ms = options['duration_ms']
      @energy = options['energy']
      @instrumentalness = options['instrumentalness']
      @key = options['key']
      @liveness = options['liveness']
      @loudness = options['loudness']
      @mode = options['mode']
      @speechiness = options['speechiness']
      @tempo = options['tempo']
      @time_signature = options['time_signature']
      @track_href = options['track_href']
      @valence = options['valence']

      super(options)
    end

    # Spotify does not support search for audio features
    def self.search(*)
      warn 'Spotify API does not support search for audio features'
      false
    end

  end
end
