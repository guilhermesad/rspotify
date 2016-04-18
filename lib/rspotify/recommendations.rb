module RSpotify

  # @attr [Array<Track>]              tracks An array of {https://developer.spotify.com/web-api/object-model/#track-object-simplified track object (simplified)} ordered according to the parameters supplied.
  # @attr [Array<RecommendationSeed>] seeds An array of {https://developer.spotify.com/web-api/object-model/#recommendations-seed-object recommendation seed objects}.
  class Recommendations < Base
    
    # Retrieve a list of available genres seed parameter values for recommendations. 
    # @return [Array<String>] 
    #
    # @example
    #          genres = RSpotify::Recommendations.available_genre_seeds
    def self.available_genre_seeds
      response = RSpotify.get('recommendations/available-genre-seeds')
      return response if RSpotify.raw_response

      response['genres']
    end

    # Create a playlist-style listening experience based on seed artists, tracks and genres
    #
    # @note Up to 5 seed values may be provided in any combination of seed_artists, seed_tracks and seed_genres.
    #
    # @param limit        [Integer]       The target size of the list of recommended tracks. For seeds with unusually small pools or when highly restrictive filtering is applied, it may be impossible to generate the requested number of recommended tracks. Debugging information for such cases is available in the response. Default: 20. Minimum: 1. Maximum: 100.
    # @param seed_artists [Array<String>] A list of Spotify IDs for seed artists.
    # @param seed_genres  [Array<String>] A list of any genres in the set of {https://developer.spotify.com/web-api/get-recommendations/#available-genre-seeds available genre seeds}.
    # @param seed_tracks  [Array<String>] A list of Spotify IDs for seed tracks.
    # @param market       [String]        Optional. An {https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2  ISO 3166-1 alpha-2 country code}. Provide this parameter if you want to apply Track Relinking. Because min_*, max_* and target_* are applied to pools before relinking, the generated results may not precisely match the filters applied. Original, non-relinked tracks are available via the linked_from attribute of the relinked track response.
    # @option options     [Float]         :min_acousticness Hard floor on the confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic.          
    # @option options     [Float]         :max_acousticness Hard ceiling on the confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic. 
    # @option options     [Float]         :target_acousticness Target value on the confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic.
    # @option options     [Float]         :min_danceability Hard floor on how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable.
    # @option options     [Float]         :max_danceability Hard ceiling on how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable.
    # @option options     [Float]         :target_danceability Target value on how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable.
    # @option options     [Integer]       :min_duration_ms Hard floor on the duration of the track in milliseconds.
    # @option options     [Integer]       :max_duration_ms Hard ceiling on the duration of the track in milliseconds.
    # @option options     [Integer]       :target_duration_ms Target value on the duration of the track in milliseconds.
    # @option options     [Float]         :min_energy Hard floor on energy which is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy.
    # @option options     [Float]         :max_energy Hard ceiling on energy which is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy.
    # @option options     [Float]         :target_energy Target value on energy which is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy.
    # @option options     [Float]         :min_instrumentalness Hard floor on prediction of whether a track contains no vocals. "Ooh" and "aah" sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly "vocal". The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0.
    # @option options     [Float]         :max_instrumentalness Hard ceiling on prediction of whether a track contains no vocals. "Ooh" and "aah" sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly "vocal". The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0.
    # @option options     [Float]         :target_instrumentalness Target value on prediction of whether a track contains no vocals. "Ooh" and "aah" sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly "vocal". The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0.
    # @option options     [Integer]       :min_key Hard floor on the key the track is in. Integers map to pitches using standard {https://en.wikipedia.org/wiki/Pitch_class Pitch Class notation}. E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on.
    # @option options     [Integer]       :max_key Hard ceiling on the key the track is in. Integers map to pitches using standard {https://en.wikipedia.org/wiki/Pitch_class Pitch Class notation}. E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on.   
    # @option options     [Integer]       :target_key Target value on the key the track is in. Integers map to pitches using standard {https://en.wikipedia.org/wiki/Pitch_class Pitch Class notation}. E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on.   
    # @option options     [Float]         :min_liveness Hard floor on liveness, which detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 provides strong likelihood that the track is live.
    # @option options     [Float]         :max_liveness Hard ceiling on liveness, which detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 provides strong likelihood that the track is live.
    # @option options     [Float]         :target_liveness Target value on liveness, which detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 provides strong likelihood that the track is live.
    # @option options     [Float]         :min_loudness Hard floor on the overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typical range between -60 and 0 db.
    # @option options     [Float]         :max_loudness Hard ceiling on the overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typical range between -60 and 0 db.
    # @option options     [Float]         :target_loudness Target value on the overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typical range between -60 and 0 db.
    # @option options     [Integer]       :min_mode Hard floor on the modality (major or minor) of a track, the type of scale from which its melodic content is derived. Major is represented by 1 and minor is 0.         
    # @option options     [Integer]       :max_mode Hard ceiling on the modality (major or minor) of a track, the type of scale from which its melodic content is derived. Major is represented by 1 and minor is 0.         
    # @option options     [Integer]       :target_mode Target value on the modality (major or minor) of a track, the type of scale from which its melodic content is derived. Major is represented by 1 and minor is 0.         
    # @option options     [Integer]       :min_popularity Hard floor on the popularity of the track. The value will be between 0 and 100, with 100 being the most popular. The popularity is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are.
    # @option options     [Integer]       :max_popularity Hard ceiling on the popularity of the track. The value will be between 0 and 100, with 100 being the most popular. The popularity is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are.
    # @option options     [Integer]       :target_popularity Target value on the popularity of the track. The value will be between 0 and 100, with 100 being the most popular. The popularity is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are.
    # @option options     [Float]         :min_speechiness Hard floor on speechiness which detects the presence of spoken words in a track. The more exclusively speech-like the recording (e.g. talk show, audio book, poetry), the closer to 1.0 the attribute value. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks.
    # @option options     [Float]         :max_speechiness Hard ceiling on speechiness which detects the presence of spoken words in a track. The more exclusively speech-like the recording (e.g. talk show, audio book, poetry), the closer to 1.0 the attribute value. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks.
    # @option options     [Float]         :target_speechiness Target value on speechiness which detects the presence of spoken words in a track. The more exclusively speech-like the recording (e.g. talk show, audio book, poetry), the closer to 1.0 the attribute value. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks.
    # @option options     [Float]         :min_tempo Hard floor on the overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration.
    # @option options     [Float]         :max_tempo Hard ceiling on the overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration.
    # @option options     [Float]         :target_tempo Target value on the overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration.
    # @option options     [Integer]       :min_time_signature Hard floor on the estimated overall time signature of a track. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure).
    # @option options     [Integer]       :max_time_signature Hard ceiling on the estimated overall time signature of a track. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure).
    # @option options     [Integer]       :target_time_signature Target value on the estimated overall time signature of a track. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure).
    # @option options     [Float]         :min_valence Hard floor on the measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).
    # @option options     [Float]         :max_valence Hard ceiling on the measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).
    # @option options     [Float]         :target_valence Target value on the measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).
    # @return [Array<Recommendations>]
    #
    # @example
    #          recommendations = RSpotify::Recommendations.generate(limit: 20, seed_tracks: ['0c6xIDDpzE81m2q797ordA'])
    #          recommendations = RSpotify::Recommendations.generate(seed_tracks: ['0c6xIDDpzE81m2q797ordA'], seed_artists: ['4NHQUGzhtTLFvgF5SZesLK'], market: 'ES')
    #          recommendations = RSpotify::Recommendations.generate(seed_tracks: ['0c6xIDDpzE81m2q797ordA'], seed_genres: ['alt_rock'], seed_artists: ['4NHQUGzhtTLFvgF5SZesLK'], target_energy: 1.0)
    def self.generate(limit: 20, seed_artists: [], seed_genres: [], seed_tracks: [], market: nil, **options)
      url = "recommendations?limit=#{limit}"

      url << "&seed_artists=#{seed_artists.join(',')}" if seed_artists.any?
      url << "&seed_genres=#{seed_genres.join(',')}" if seed_genres.any?
      url << "&seed_tracks=#{seed_tracks.join(',')}" if seed_tracks.any?

      options.each do |option, value|
        url << "&#{option}=#{value}"
      end

      response = if market.is_a? Hash
        url << '&market=from_token'
        User.oauth_get(market[:from].id, url)
      else
        url << "&market=#{market}" if market
        RSpotify.get(url)
      end

      return response if RSpotify.raw_response

      Recommendations.new response
    end

    def initialize(options = {})
      @seeds = options['seeds'].map { |i| RecommendationSeed.new i }
      @tracks = options['tracks'].map { |i| Track.new i }

      super(options)
    end
  end

end
