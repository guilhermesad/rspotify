describe RSpotify::User do

  describe 'User::find' do

    before(:each) do
      # Get wizzler user as a testing sample
      @user = VCR.use_cassette('user:find:wizzler') do
        RSpotify::User.find('wizzler')
      end
    end

    it 'should find user with correct attributes' do
      expect(@user.external_urls['spotify']) .to eq 'https://open.spotify.com/user/wizzler'
      expect(@user.followers['total'])       .to be > 0
      expect(@user.href)                     .to eq 'https://api.spotify.com/v1/users/wizzler'
      expect(@user.id)                       .to eq 'wizzler'
      expect(@user.type)                     .to eq 'user'
      expect(@user.uri)                      .to eq 'spotify:user:wizzler'
    end

    it 'should find user with correct playlists' do
      # Keys generated specifically for the tests. Should be removed in the future
      client_id     = '5ac1cda2ad354aeaa1ad2693d33bb98c'
      client_secret = '155fc038a85840679b55a1822ef36b9b'
      authenticate_client

      playlists = VCR.use_cassette('user:wizzler:playlists:limit:20:offset:0') do
        @user.playlists
      end
      expect(playlists)             .to be_an Array
      expect(playlists.size)        .to eq 6
      expect(playlists.first)       .to be_an RSpotify::Playlist
      expect(playlists.map(&:name)) .to include('Movie Soundtrack Masterpieces', 'Blue Mountain State', 'Video Game Masterpieces')
    end
  end
end
