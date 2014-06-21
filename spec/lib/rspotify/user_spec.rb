describe RSpotify::User do

  describe 'User#find' do
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
  end
end
