describe RSpotify::Album do

  describe 'valid album' do
    
    before(:each) do
      # Get Arctic monkeys's AM album
      @album = RSpotify::Album.find('5bU1XKYxHhEwukllT20xtk')
    end

    it 'should have correct attributes' do
      expect(@album.album_type)               .to eq      'album'
      expect(@album.available_markets)        .to include *%w(AD AT BE BG CA EE ES FR GR MC TW US)
      expect(@album.external_ids['upc'])      .to eq      '887828031795'
      expect(@album.external_urls['spotify']) .to eq      'https://open.spotify.com/album/5bU1XKYxHhEwukllT20xtk'
      expect(@album.genres)                   .to include 'Indie'
      expect(@album.href)                     .to eq      'https://api.spotify.com/v1/albums/5bU1XKYxHhEwukllT20xtk'
      expect(@album.id)                       .to eq      '5bU1XKYxHhEwukllT20xtk'
      expect(@album.images)                   .to include ({'height' => 640, 'width' => 640, 'url' => 'https://i.scdn.co/image/4d9ec146e3a257b10634d9a413ef6cc3de325008'})
      expect(@album.name)                     .to eq      'AM'
      expect(@album.popularity)               .to be      > 0
      expect(@album.release_date)             .to eq      '2013-09-09'
      expect(@album.release_date_precision)   .to eq      'day'
      expect(@album.type)                     .to eq      'album'
      expect(@album.uri)                      .to eq      'spotify:album:5bU1XKYxHhEwukllT20xtk'
    end

    it 'should have correct nested attributes' do
      #TODO
    end
  end
end
