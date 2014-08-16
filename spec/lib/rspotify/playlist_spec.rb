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
      expect(tracks)             .to be_an RSpotify::ResponsePage
      expect(tracks.size)        .to eq 50
      expect(tracks.first)       .to be_an RSpotify::Track
      expect(tracks.map(&:name)) .to include('Waking Up', 'Honor Him', 'Circle of Life', 'Time')
    end
  end
end
