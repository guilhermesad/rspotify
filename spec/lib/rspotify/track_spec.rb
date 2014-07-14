describe RSpotify::Track do

  describe 'Track::find receiving id as a string' do
    
    before(:each) do
      # Get Arctic Monkeys's "Do I Wanna Know?" track as a testing sample
      @track = RSpotify::Track.find('3jfr0TF6DQcOLat8gGn7E2')
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
  end

  describe 'Track::find receiving array of ids' do
    it 'should find the right tracks' do
      ids = ['4oI9kesyxHUr8fqiLd6uO9']
      tracks = RSpotify::Track.find(ids)
      expect(tracks)            .to be_an Array
      expect(tracks.size)       .to eq 1
      expect(tracks.first.name) .to eq 'The Next Day'

      ids << '7D8BAYkrR9peCB9XSKCADc'
      tracks = RSpotify::Track.find(ids)
      expect(tracks)            .to be_an Array
      expect(tracks.size)       .to eq 2
      expect(tracks.first.name) .to eq 'The Next Day'
      expect(tracks.last.name)  .to eq 'Sunday'
    end
  end

  describe 'Track::search' do
    it 'should search for the right tracks' do
      tracks = RSpotify::Track.search('Wanna Know')
      expect(tracks)             .to be_an Array
      expect(tracks.size)        .to eq 20
      expect(tracks.first)       .to be_an RSpotify::Track
      expect(tracks.map(&:name)) .to include('Do I Wanna Know?', 'I Wanna Know', 'Never Wanna Know')
    end

    it 'should accept additional options' do
      tracks = RSpotify::Track.search('Wanna Know', limit: 10)
      expect(tracks.size)        .to eq 10
      expect(tracks.map(&:name)) .to include('Do I Wanna Know?', 'I Wanna Know')

      tracks = RSpotify::Track.search('Wanna Know', offset: 10)
      expect(tracks.size)        .to eq 20
      expect(tracks.map(&:name)) .to include('They Wanna Know', 'Say I Wanna Know')

      tracks = RSpotify::Track.search('Wanna Know', limit: 10, offset: 10)
      expect(tracks.size)        .to eq 10
      expect(tracks.map(&:name)) .to include('They Wanna Know')
    end
  end
end
