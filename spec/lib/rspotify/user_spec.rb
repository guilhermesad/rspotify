describe RSpotify::User do

  describe 'User::find' do

    before(:each) do
      # Get wizzler user as a testing sample
      @user = RSpotify::User.find('wizzler')
    end

    it 'should find user with correct attributes' do
      expect(@user.external_urls['spotify']) .to eq 'https://open.spotify.com/user/wizzler'
      expect(@user.href)                     .to eq 'https://api.spotify.com/v1/users/wizzler'
      expect(@user.id)                       .to eq 'wizzler'
      expect(@user.type)                     .to eq 'user'
      expect(@user.uri)                      .to eq 'spotify:user:wizzler'
    end

    it 'should find user with correct playlists' do
      # Keys generated specifically for the tests. Should be removed in the future
      client_id     = '5ac1cda2ad354aeaa1ad2693d33bb98c'
      client_secret = '155fc038a85840679b55a1822ef36b9b'
      RSpotify.authenticate(client_id, client_secret)

      playlists = @user.playlists
      expect(playlists)             .to be_an Array
      expect(playlists.size)        .to eq 7
      expect(playlists.first)       .to be_an RSpotify::Playlist
      expect(playlists.map(&:name)) .to include('Movie Soundtrack Masterpieces', 'Blue Mountain State', 'Starred')
    end
  end
end
