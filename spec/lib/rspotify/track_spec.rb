describe RSpotify::Track do

  describe 'Track::find receiving id as a string' do

    before(:each) do
      # Get Arctic Monkeys's "Do I Wanna Know?" track as a testing sample
      @track = VCR.use_cassette('track:find:3jfr0TF6DQcOLat8gGn7E2') do
        RSpotify::Track.find('3jfr0TF6DQcOLat8gGn7E2')
      end
    end

    it 'should find track with correct attributes' do
      expect(@track.available_markets)        .to include *%w(AD AT BE BG CA EE ES FR GR MC TW US)
      expect(@track.disc_number)              .to eq 1
      expect(@track.duration_ms)              .to eq 272_394
      expect(@track.explicit)                 .to eq false
      expect(@track.external_ids['isrc'])     .to eq 'GBCEL1300362'
      expect(@track.external_urls['spotify']) .to eq 'https://open.spotify.com/track/3jfr0TF6DQcOLat8gGn7E2'
      expect(@track.href)                     .to eq 'https://api.spotify.com/v1/tracks/3jfr0TF6DQcOLat8gGn7E2'
      expect(@track.id)                       .to eq '3jfr0TF6DQcOLat8gGn7E2'
      expect(@track.name)                     .to eq 'Do I Wanna Know?'
      expect(@track.popularity)               .to be > 0
      expect(@track.preview_url)              .to eq 'https://p.scdn.co/mp3-preview/c181f36e2fe0fb41885cb83a8fe9f76480952701'
      expect(@track.track_number)             .to eq 1
      expect(@track.type)                     .to eq 'track'
      expect(@track.uri)                      .to eq 'spotify:track:3jfr0TF6DQcOLat8gGn7E2'
    end

    it 'should find track with correct album' do
      album = @track.album
      expect(album)      .to be_an RSpotify::Album
      expect(album.id)   .to eq '5bU1XKYxHhEwukllT20xtk'
      expect(album.name) .to eq 'AM'
    end

    it 'should find track with correct artists' do
      artists = @track.artists
      expect(artists)             .to be_an Array
      expect(artists.size)        .to eq 1
      expect(artists.first)       .to be_an RSpotify::Artist
      expect(artists.map(&:name)) .to include('Arctic Monkeys')
    end

    it 'should find a track available in the given market' do
      track = VCR.use_cassette('track:find:3jfr0TF6DQcOLat8gGn7E2:market:ES') do
        RSpotify::Track.find('3jfr0TF6DQcOLat8gGn7E2', market: 'ES')
      end

      expect(track.id)                        .to eq '5FVd6KXrgO9B3JPmC8OPst'
      expect(track.is_playable)               .to be true
      expect(track.linked_from.id)            .to eq '3jfr0TF6DQcOLat8gGn7E2'
      expect(track.linked_from.href)          .to eq 'https://api.spotify.com/v1/tracks/3jfr0TF6DQcOLat8gGn7E2'
      expect(track.linked_from.type)          .to eq 'track'
      expect(track.linked_from.uri)           .to eq 'spotify:track:3jfr0TF6DQcOLat8gGn7E2'
      expect(track.linked_from.external_urls) .to eq('spotify' => 'https://open.spotify.com/track/3jfr0TF6DQcOLat8gGn7E2')
    end

    it 'should find a track which is unavailable in the given market' do
      track = VCR.use_cassette('track:find:6fi8e1nv4QBqODf9puRcyX:market:ES') do
        RSpotify::Track.find('6fi8e1nv4QBqODf9puRcyX', market: 'ES')
      end

      expect(track.id)          .to eq '6fi8e1nv4QBqODf9puRcyX'
      expect(track.is_playable) .to be false
    end
  end

  describe 'Track::find receiving array of ids' do
    it 'should find the right tracks' do
      ids = ['4oI9kesyxHUr8fqiLd6uO9']
      tracks = VCR.use_cassette('track:find:4oI9kesyxHUr8fqiLd6uO9') do
        RSpotify::Track.find(ids)
      end
      expect(tracks)            .to be_an Array
      expect(tracks.size)       .to eq 1
      expect(tracks.first.name) .to eq 'The Next Day'

      ids << '7D8BAYkrR9peCB9XSKCADc'
      tracks = VCR.use_cassette('track:find:7D8BAYkrR9peCB9XSKCADc') do
        RSpotify::Track.find(ids)
      end
      expect(tracks)            .to be_an Array
      expect(tracks.size)       .to eq 2
      expect(tracks.first.name) .to eq 'The Next Day'
      expect(tracks.last.name)  .to eq 'Sunday'
    end

    it 'should find tracks available in the given market' do
      ids = ['4oI9kesyxHUr8fqiLd6uO9']
      tracks = VCR.use_cassette('track:find:4oI9kesyxHUr8fqiLd6uO9:market:ES') do
        RSpotify::Track.find(ids, market: 'ES')
      end
      expect(tracks)                      .to be_an Array
      expect(tracks.size)                 .to eq 1
      expect(tracks.first.id)             .to eq '1CFz8ZV88CFLwmggjGrW4c'
      expect(tracks.first.linked_from.id) .to eq '4oI9kesyxHUr8fqiLd6uO9'
    end
  end

  describe 'Track::search' do
    it 'should search for the right tracks' do
      tracks = VCR.use_cassette('track:search:Wanna Know') do
        RSpotify::Track.search('Wanna Know')
      end
      expect(tracks)             .to be_an Array
      expect(tracks.size)        .to eq 20
      expect(tracks.total)       .to eq 4834
      expect(tracks.first)       .to be_an RSpotify::Track
      expect(tracks.map(&:name)) .to include('Do I Wanna Know?', 'I Wanna Know', 'I Just Wanna Know')
    end

    it 'should accept additional options' do
      tracks = VCR.use_cassette('track:search:Wanna Know:limit:10') do
        RSpotify::Track.search('Wanna Know', limit: 10)
      end
      expect(tracks.size)        .to eq 10
      expect(tracks.map(&:name)) .to include('Do I Wanna Know?', 'I Wanna Know')

      tracks = VCR.use_cassette('track:search:Wanna Know:offset:10') do
        RSpotify::Track.search('Wanna Know', offset: 10)
      end
      expect(tracks.size)        .to eq 20
      expect(tracks.map(&:name)) .to include('Wanna Know')

      tracks = VCR.use_cassette('track:search:Wanna Know:limit:10:offset:10') do
        RSpotify::Track.search('Wanna Know', limit: 10, offset: 10)
      end
      expect(tracks.size)        .to eq 10
      expect(tracks.map(&:name)) .to include('Wanna Know')

      tracks = VCR.use_cassette('track:search:Wanna Know:market:ES') do
        RSpotify::Track.search('Wanna Know', market: 'ES')
      end
      ES_tracks = tracks.select { |t| t.available_markets.include?('ES') }
      expect(ES_tracks.length).to eq(tracks.length)
    end
  end

  describe 'Track#audio_features' do
    let(:client_id) { '5ac1cda2ad354aeaa1ad2693d33bb98c' }
    let(:client_secret) { '155fc038a85840679b55a1822ef36b9b' }

    before do
      authenticate_client
    end

    let(:track) do
      VCR.use_cassette('track:find:3jfr0TF6DQcOLat8gGn7E2') do
        RSpotify::Track.find('3jfr0TF6DQcOLat8gGn7E2')
      end
    end

    it 'retrieves the audio features for the track' do
      audio_features = VCR.use_cassette('track:audio_features:3jfr0TF6DQcOLat8gGn7E2') do
        track.audio_features
      end

      expect(audio_features.acousticness).to     eq 0.186
      expect(audio_features.analysis_url).to     eq 'https://api.spotify.com/v1/audio-analysis/3jfr0TF6DQcOLat8gGn7E2'
      expect(audio_features.danceability).to     eq 0.548
      expect(audio_features.duration_ms).to      eq 272394
      expect(audio_features.energy).to           eq 0.532
      expect(audio_features.instrumentalness).to eq 0.000263
      expect(audio_features.key).to              eq 5
      expect(audio_features.liveness).to         eq 0.217
      expect(audio_features.loudness).to         eq -7.596
      expect(audio_features.mode).to             eq 1
      expect(audio_features.speechiness).to      eq 0.0323
      expect(audio_features.tempo).to            eq 85.030
      expect(audio_features.time_signature).to   eq 4
      expect(audio_features.track_href).to       eq 'https://api.spotify.com/v1/tracks/3jfr0TF6DQcOLat8gGn7E2'
      expect(audio_features.valence).to          eq 0.428
    end
  end
end
