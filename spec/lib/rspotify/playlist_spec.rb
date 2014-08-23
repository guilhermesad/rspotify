describe RSpotify::Playlist do

  describe 'Playlist::find' do
    
    before(:each) do
      stubbed_authenticate_test_account

      # Get wizzler's "Movie Soundtrack Masterpieces" playlist as a testing sample
      @playlist = VCR.use_cassette('playlist:find:wizzler:00wHcTN0zQiun4xri9pmvX') do 
        RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX')
      end
    end

    it 'should find playlist with correct attributes' do
      expect(@playlist.collaborative)            .to eq    false
      expect(@playlist.external_urls['spotify']) .to eq    'http://open.spotify.com/user/wizzler/playlist/00wHcTN0zQiun4xri9pmvX'
      expect(@playlist.description)              .to match /Iconic soundtracks featured in some of the greatest movies/
      expect(@playlist.followers['total'])       .to be    > 0
      expect(@playlist.href)                     .to eq    'https://api.spotify.com/v1/users/wizzler/playlists/00wHcTN0zQiun4xri9pmvX'
      expect(@playlist.id)                       .to eq    '00wHcTN0zQiun4xri9pmvX'
      expect(@playlist.images.first['url'])      .to match %r{https://dv72vokf4bztv\.cloudfront}
      expect(@playlist.name)                     .to eq    'Movie Soundtrack Masterpieces'
      expect(@playlist.public)                   .to eq    true
      expect(@playlist.type)                     .to eq    'playlist'
      expect(@playlist.uri)                      .to eq    'spotify:user:wizzler:playlist:00wHcTN0zQiun4xri9pmvX'
    end

    it 'should find playlist with correct owner' do
      owner = @playlist.owner
      expect(owner)    .to be_an RSpotify::User
      expect(owner.id) .to eq 'wizzler'
    end

    it 'should find playlist with correct tracks' do
      tracks = @playlist.tracks
      expect(tracks)             .to be_an Array
      expect(tracks.size)        .to eq 50
      expect(tracks.first)       .to be_an RSpotify::Track
      expect(tracks.map(&:name)) .to include('Waking Up', 'Honor Him', 'Circle of Life', 'Time')
    end
  end

  describe 'playlist::tracks with multiple pages of data' do 

    before(:each) do 
      VCR.use_cassette('playlist:find:spilliton:71LUUNEsUJTmF36U077MJ7') do 
        authenticate_test_account
        @playlist = RSpotify::Playlist.find('spilliton', '71LUUNEsUJTmF36U077MJ7')
        @tracks = @playlist.tracks
      end
    end

    it 'should have fetched all the pages of tracks into an array' do 
      expect(@tracks.length)   .to eq    102
      expect(@tracks.first)    .to be_an RSpotify::Track
    end

    it 'should fetch a specific range of tracks' do 
      VCR.use_cassette('playlist:tracks:spilliton:71LUUNEsUJTmF36U077MJ7') do 
        authenticate_test_account
        @tracks = @playlist.tracks(limit: 5, offset: 10)
      end

      expect(@tracks.length)            .to eq    5
      expect(@tracks)                   .to be_an Array

      track = @tracks.first
      expect(track)                     .to be_an RSpotify::Track
      expect(track.name)                .to eq    'Sodom, South Georgia'
      expect(track.artists.first.name)  .to eq    'Iron & Wine'
      expect(track.album.name)          .to eq    'Our Endless Numbered Days'
    end

  end
end
