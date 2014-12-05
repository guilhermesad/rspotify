describe RSpotify::Playlist do

  # Keys generated specifically for the tests. Should be removed in the future
  let(:client_id) { '5ac1cda2ad354aeaa1ad2693d33bb98c' }
  let(:client_secret) { '155fc038a85840679b55a1822ef36b9b' }
  let(:starred_playlist) do
    VCR.use_cassette('playlist:find:118430647:starred') do
      RSpotify::Playlist.find('118430647', 'starred')
    end
  end

  before do
    VCR.use_cassette('authenticate:client') do
      RSpotify.authenticate(client_id, client_secret)
    end
  end

  describe 'Playlist::browse_featured' do
    it 'should find the appropriate featured playlists' do
      playlists = VCR.use_cassette('playlist:browse_featured') do 
        RSpotify::Playlist.browse_featured
      end
      expect(playlists.size)        .to eq 13
      expect(playlists.map(&:name)) .to include('Dance Mega Mix', 'Peaceful Piano', 'Sleep')
    end

    it 'should accept additional options' do
      playlists = VCR.use_cassette('playlist:browse_featured:limit:10:offset:10') do 
        RSpotify::Playlist.browse_featured(limit: 10, offset: 10)
      end
      expect(playlists.size)        .to eq 3
      expect(playlists.map(&:name)) .to include('Sleep', 'Late Night R&B')

      playlists = VCR.use_cassette('playlist:browse_featured:locale:es_MX') do 
        RSpotify::Playlist.browse_featured(locale: 'es_MX')
      end
      expect(playlists.size)        .to eq 13
      expect(playlists.map(&:name)) .to include('Dance Mega Mix', 'Peaceful Piano', 'Sleep')

      playlists = VCR.use_cassette('playlist:browse_featured:country:ES:timestamp:2014-10-23T09:00:00') do 
        RSpotify::Playlist.browse_featured(country: 'ES', timestamp: '2014-10-23T09:00:00')
      end
      expect(playlists.size)        .to eq 17
      expect(playlists.map(&:name)) .to include('En el trabajo', 'En las Nubes')
    end
  end

  describe 'Playlist::find' do

    let(:playlist) do
      # Get wizzler's "Movie Soundtrack Masterpieces" playlist as a testing sample
      VCR.use_cassette('playlist:find:wizzler:00wHcTN0zQiun4xri9pmvX') do
        RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX')
      end
    end

    it 'should find playlist with correct attributes' do
      expect(playlist.collaborative)            .to eq    false
      expect(playlist.external_urls['spotify']) .to eq    'http://open.spotify.com/user/wizzler/playlist/00wHcTN0zQiun4xri9pmvX'
      expect(playlist.description)              .to match /Iconic soundtracks featured in some of the greatest movies/
      expect(playlist.followers['total'])       .to be    > 0
      expect(playlist.href)                     .to eq    'https://api.spotify.com/v1/users/wizzler/playlists/00wHcTN0zQiun4xri9pmvX'
      expect(playlist.id)                       .to eq    '00wHcTN0zQiun4xri9pmvX'
      expect(playlist.images.first['url'])      .to match %r{https://i\.scdn\.co/image/418ce596327dc3a0f4d377db80421bffb3b94a9a}
      expect(playlist.name)                     .to eq    'Movie Soundtrack Masterpieces'
      expect(playlist.public)                   .to eq    true
      expect(playlist.type)                     .to eq    'playlist'
      expect(playlist.uri)                      .to eq    'spotify:user:wizzler:playlist:00wHcTN0zQiun4xri9pmvX'
    end

    it 'should find playlist with correct owner' do
      owner = playlist.owner
      expect(owner)    .to be_an RSpotify::User
      expect(owner.id) .to eq 'wizzler'
    end

    it 'should find playlist with correct tracks' do
      tracks = playlist.tracks
      expect(tracks)             .to be_an Array
      expect(tracks.size)        .to eq 53
      expect(tracks.first)       .to be_an RSpotify::Track
      expect(tracks.map(&:name)) .to include('Waking Up', 'Honor Him', 'Circle Of Life - From "The Lion King"', 'Time')
    end

    context 'starred playlist' do
      it "should support starred playlists" do
        expect(starred_playlist.name).to  eq "Starred"
        expect(starred_playlist.href).to   eq "https://api.spotify.com/v1/users/118430647/starred"
      end
    end
  end

  describe 'Playlist::search' do
    it 'should search for the right playlists' do
      playlists = VCR.use_cassette('playlist:search:Indie') do 
        RSpotify::Playlist.search('Indie')
      end
      expect(playlists)             .to be_an Array
      expect(playlists.size)        .to eq 20
      expect(playlists.first)       .to be_an RSpotify::Playlist
      expect(playlists.map(&:name)) .to include('The Indie Mix', 'Indie Folk', 'Alt/Indie')
    end

    it 'should accept additional options' do
      playlists = VCR.use_cassette('playlist:search:Indie:limit:10') do 
        RSpotify::Playlist.search('Indie', limit: 10)
      end
      expect(playlists.size)        .to eq 10
      expect(playlists.map(&:name)) .to include('The Indie Mix', 'Indie Folk')

      playlists = VCR.use_cassette('playlist:search:Indie:offset:10') do 
        RSpotify::Playlist.search('Indie', offset: 10)
      end
      expect(playlists.size)        .to eq 20
      expect(playlists.map(&:name)) .to include('Indie Workout', 'Indie Brunch')

      playlists = VCR.use_cassette('playlist:search:Indie:offset:10:limit:10') do 
        RSpotify::Playlist.search('Indie', limit: 10, offset: 10)
      end
      expect(playlists.size)        .to eq 10
      expect(playlists.map(&:name)) .to include('Infinite Indie')
    end
  end

  describe 'Playlist#tracks' do
    it 'should fetch more tracks correctly' do
      tracks = VCR.use_cassette('playlist:tracks:118430647:starred') do
        starred_playlist.tracks(offset: 100, limit: 100)
      end
      expect(tracks)           .to be_an Array
      expect(tracks.size)      .to eq 85
      expect(tracks.last.name) .to eq 'On The Streets - Kollectiv Turmstrasse Let Freedom Ring Remix'
    end

    it 'should have time that track was added' do
      tracks = VCR.use_cassette('playlist:tracks:118430647:starred') do
        starred_playlist.tracks(offset: 0, limit: 100)
      end
      expected_time = Time.parse('2012-08-05T16:28:24Z')
      expect(starred_playlist.added_times[tracks.first.id]) .to eq(expected_time)
    end

    it 'should have information about user that added the track' do
      tracks = VCR.use_cassette('playlist:tracks:118430647:starred') do
        starred_playlist.tracks(offset: 0, limit: 100)
      end
      index_with_added_by_data = 97
      expect(starred_playlist.added_by[tracks[index_with_added_by_data].id]) .to eq('118430647')
    end
  end

  describe 'Playlist#complete!' do
    let(:href) { 'https://api.spotify.com/v1/users/wizzler/playlists/00wHcTN0zQiun4xri9pmvX' }
    let(:playlist) { RSpotify::Playlist.new('href' => href, 'owner' => {'id' => 'wizzler'}) }

    it 'should fetch the complete information correctly' do
      VCR.use_cassette('playlist:find:wizzler:00wHcTN0zQiun4xri9pmvX') do
        playlist.complete!
      end
      expect(playlist.name).to eq 'Movie Soundtrack Masterpieces'
    end
  end
end
