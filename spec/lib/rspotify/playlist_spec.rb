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
    authenticate_client
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
      expect(playlists.size)        .to eq 20
      expect(playlists.map(&:name)) .to include('New Music Friday', 'Peaceful Piano')

      playlists = VCR.use_cassette('playlist:browse_featured:country:ES:timestamp:2014-10-23T09:00:00') do
        RSpotify::Playlist.browse_featured(country: 'ES', timestamp: '2014-10-23T09:00:00')
      end
      expect(playlists.size)        .to eq 20
      expect(playlists.map(&:name)) .to include('De Camino')
    end
  end

  describe "Playlist::find_by_id" do
    let(:playlist) do
      # Get wizzler's "Movie Soundtrack Masterpieces" playlist as a testing sample
      VCR.use_cassette('playlist:find_by_id:37i9dQZF1DX1R3yDogYrbo') do
        RSpotify::Playlist.find_by_id('37i9dQZF1DX1R3yDogYrbo')
      end
    end

    it 'gets playlist attributes' do
      expect(playlist.collaborative)            .to eq false
      expect(playlist.external_urls['spotify']) .to eq    'https://open.spotify.com/playlist/37i9dQZF1DX1R3yDogYrbo'
      expect(playlist.description)              .to match /Ouça os grandes sucessos e parcerias de um dos maiores nomes da música brasileira./
      expect(playlist.followers['total'])       .to eq 77654
      expect(playlist.href)                     .to eq    'https://api.spotify.com/v1/playlists/37i9dQZF1DX1R3yDogYrbo'
      expect(playlist.id)                       .to eq    '37i9dQZF1DX1R3yDogYrbo'
      expect(playlist.images.first['url'])      .to match %r{https://i\.scdn\.co/image/270b576e45bc1bfb10ab624c63857360c02fed6f}
      expect(playlist.name)                     .to eq    'This Is Caetano Veloso'
      expect(playlist.public)                   .to eq    false
      expect(playlist.snapshot_id)              .to eq    'MTUyNzIxODU5NywwMDAwMDAwYTAwMDAwMTYzOTU1MjZjODgwMDAwMDE2MmYyYjBlOGQ4'
      expect(playlist.total)                    .to eq    57
      expect(playlist.type)                     .to eq    'playlist'
      expect(playlist.uri)                      .to eq    'spotify:user:spotify:playlist:37i9dQZF1DX1R3yDogYrbo'
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
      expect(playlist.snapshot_id)              .to eq    'fJBjh16iZclZtApl/xyzPNjOp38sPqefUQkEhP94N4mf/+4F6MbRjwR+PSP/Cnys'
      expect(playlist.total)                    .to eq    54
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
      expect(tracks.size)        .to eq 54
      expect(tracks.first)       .to be_an RSpotify::Track
      expect(tracks.map(&:name)) .to include('Waking Up', 'Honor Him', 'Circle Of Life - From "The Lion King"', 'Time')
    end

    it 'should find playlist with correct times each track was added' do
      tracks_added_at = playlist.tracks_added_at
      expect(tracks_added_at.size).to eq 54

      track_id = '2o660Ri2wTg7Rv6cKbFBCe'
      expected_time = Time.parse('2014-04-20T20:52:42Z')
      expect(tracks_added_at[track_id]).to eq expected_time
    end

    it 'should find playlist with correct users that added each track' do
      tracks_added_by = playlist.tracks_added_by
      expect(tracks_added_by.size).to eq 54

      track_id = '2o660Ri2wTg7Rv6cKbFBCe'
      expected_user_id = 'wizzler'
      expect(tracks_added_by[track_id].class).to eq RSpotify::User
      expect(tracks_added_by[track_id].id).to eq expected_user_id
    end

    it 'should find playlist showing correctly which track is local or not' do
      tracks_is_local = playlist.tracks_is_local
      expect(tracks_is_local.size).to eq 54

      track_id = '2o660Ri2wTg7Rv6cKbFBCe'
      expect(tracks_is_local[track_id]).to eq false
    end

    it 'should find playlist tracks that are available in the given market' do
      playlist_in_market = VCR.use_cassette('playlist:find:00wHcTN0zQiun4xri9pmvX:market:ES') do
        RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX', market: 'ES')
      end

      expect(playlist_in_market.tracks[1].id) .to eq '6roJqzCHo3nZBI1TrbsKhn'
    end

    context 'starred playlist' do
      it "should support starred playlists" do
        expect(starred_playlist.name) .to eq 'Starred'
        expect(starred_playlist.href) .to eq 'https://api.spotify.com/v1/users/118430647/starred'
        expect(starred_playlist.total).to eq 185
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
      expect(playlists.total)       .to eq 218994
      expect(playlists.first)       .to be_an RSpotify::Playlist
      expect(playlists.map(&:name)) .to include('Ultimate Indie')
    end

    it 'should accept additional options' do
      playlists = VCR.use_cassette('playlist:search:Indie:limit:10') do
        RSpotify::Playlist.search('Indie', limit: 10)
      end
      expect(playlists.size)        .to eq 10
      expect(playlists.map(&:name)) .to include('Ultimate Indie')

      playlists = VCR.use_cassette('playlist:search:Indie:offset:10') do
        RSpotify::Playlist.search('Indie', offset: 10)
      end
      expect(playlists.size)        .to eq 20
      expect(playlists.map(&:name)) .to include('Indie Acoustic')

      playlists = VCR.use_cassette('playlist:search:Indie:offset:10:limit:10') do
        RSpotify::Playlist.search('Indie', limit: 10, offset: 10)
      end
      expect(playlists.size)        .to eq 10
      expect(playlists.map(&:name)) .to include('Indie Acoustic')
    end

    it 'should work when user_id has question mark character' do
      VCR.use_cassette('playlist:search:Bird:limit:7') do
        list = RSpotify::Playlist.search("\"Andrew Bird\"", limit: 7)
        expect(list[6].followers['total']).to eq(77)
      end
    end

    it 'should work when user_id has brackets' do
      VCR.use_cassette('playlist:search:Caramell:limit:10') do
        list = RSpotify::Playlist.search("\"Caramell\"", limit: 10)
        expect(list[7].followers['total']).to eq(0)
      end
    end
  end

  describe 'Playlist#tracks' do
    use_vcr_cassette 'playlist:tracks:118430647:starred'

    before { @tracks = starred_playlist.tracks(offset: 100, limit: 100) }

    it 'should fetch more tracks correctly' do
      expect(@tracks)           .to be_an Array
      expect(@tracks.size)      .to eq 85
      expect(@tracks.last.name) .to eq 'On The Streets - Kollectiv Turmstrasse Let Freedom Ring Remix'
    end

    it 'should fetch tracks of playlists whose user has special characters in its name' do
      playlist = VCR.use_cassette('playlist:find_by_id:4dn0iEoAxn69ea0Tyov8V5') do
        RSpotify::Playlist.find_by_id('4dn0iEoAxn69ea0Tyov8V5')
      end

      tracks = VCR.use_cassette('playlist:4dn0iEoAxn69ea0Tyov8V5:tracks:offset:100') do
        playlist.tracks(offset: 100)
      end

      expect(tracks)         .to be_an Array
      expect(tracks.size)    .to eq 100
      expect(tracks[2].name) .to eq 'Nothing Left To Lose Now (Fieldhead Remix)'
    end
  end

  describe 'Playlist#complete!' do
    let(:href) { 'https://api.spotify.com/v1/users/wizzler/playlists/00wHcTN0zQiun4xri9pmvX' }
    let(:playlist) do
      min_attrs = {
        'id'   => '00wHcTN0zQiun4xri9pmvX',
        'href'   => href,
        'owner'  => {'id' => 'wizzler'},
        'tracks' => {'total' => 53 }
      }
      RSpotify::Playlist.new(min_attrs)
    end

    it 'should fetch the complete information correctly' do
      VCR.use_cassette('playlist:find:wizzler:00wHcTN0zQiun4xri9pmvX') do
        playlist.complete!
      end
      expect(playlist.name).to eq 'Movie Soundtrack Masterpieces'
    end
  end

  describe 'Playlist#is_followed_by?' do
    let(:playlist) do
      VCR.use_cassette('playlist:find:spotify:4LO89Y0ydu8li9Phq2iwKT') do
        RSpotify::Playlist.find('spotify', '4LO89Y0ydu8li9Phq2iwKT')
      end
    end

    let(:spotify) do
      VCR.use_cassette('user:find:spotify') do
        RSpotify::User.find('spotify')
      end
    end

    let(:wizzler) do
      VCR.use_cassette('user:find:wizzler') do
        RSpotify::User.find('wizzler')
      end
    end

    it "should say if it's followed by the specified users" do
      response = VCR.use_cassette('playlist:is_followed_by') do
        playlist.is_followed_by? [spotify, wizzler]
      end
      expect(response).to eq [true, false]
    end
  end
end
