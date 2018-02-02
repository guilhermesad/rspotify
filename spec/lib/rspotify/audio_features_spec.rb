describe RSpotify::AudioFeatures do

  let(:client_id) { '5ac1cda2ad354aeaa1ad2693d33bb98c' }
  let(:client_secret) { '155fc038a85840679b55a1822ef36b9b' }

  before do
    authenticate_client
  end

  describe 'AudioFeatures::find' do
    it 'finds the audio features for a track' do
      audio_features = VCR.use_cassette('audio_features:find:1zHlj4dQ8ZAtrayhuDDmkY') do
        RSpotify::AudioFeatures.find('1zHlj4dQ8ZAtrayhuDDmkY')
      end

      expect(audio_features.acousticness).to     eq 0.0362
      expect(audio_features.analysis_url).to     eq 'http://echonest-analysis.s3.amazonaws.com/TR/NJIkNQOAcm9QRI6VoxQ8KKj3xlFtyh3AFpxuKABMGuAx1sXx1ysxdaHiZ8ZzwBC6KE3HiPd00yLPrRTog=/3/full.json?AWSAccessKeyId=AKIAJRDFEY23UEVW42BQ&Expires=1460038539&Signature=ZqgmK8XH15lLPwGlKZnLJp2wgbs%3D'
      expect(audio_features.danceability).to     eq 0.587
      expect(audio_features.duration_ms).to      eq 204053
      expect(audio_features.energy).to           eq 0.965
      expect(audio_features.instrumentalness).to eq 0
      expect(audio_features.key).to              eq 11
      expect(audio_features.liveness).to         eq 0.138
      expect(audio_features.loudness).to         eq -4.106
      expect(audio_features.mode).to             eq 1
      expect(audio_features.speechiness).to      eq 0.101
      expect(audio_features.tempo).to            eq 129.972
      expect(audio_features.time_signature).to   eq 4
      expect(audio_features.track_href).to       eq 'https://api.spotify.com/v1/tracks/1zHlj4dQ8ZAtrayhuDDmkY'
      expect(audio_features.valence).to          eq 0.818
    end

    it 'finds the audio features for multiple tracks' do
      audio_features = VCR.use_cassette('audio_features:find:multiple') do
        RSpotify::AudioFeatures.find(['1zHlj4dQ8ZAtrayhuDDmkY', '7ouMYWpwJ422jRcDASZB7P', '4VqPOruhp5EdPBeR92t6lQ'])
      end

      expect(audio_features.count).to eq 3
    end
  end

end
