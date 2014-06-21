describe RSpotify::Album do

  describe 'Album#find' do
    
    before(:each) do
      # Get Arctic Monkeys's AM album as a testing sample
      @album = RSpotify::Album.find('5bU1XKYxHhEwukllT20xtk')
    end

    it 'should find album with correct attributes' do
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

    it 'should find album with correct artists' do
      artists = @album.artists
      expect(artists)             .to be_an Array
      expect(artists.size)        .to eq 1
      expect(artists.first)       .to be_an RSpotify::Artist
      expect(artists.map(&:name)) .to include('Arctic Monkeys')
    end

    it 'should find album with correct tracks' do
      tracks = @album.tracks
      expect(tracks)             .to be_an Array
      expect(tracks.size)        .to eq 12
      expect(tracks.first)       .to be_an RSpotify::Track
      expect(tracks.map(&:name)) .to include('Do I Wanna Know?', 'R U Mine?', 'Arabella', 'Fireside')
    end
  end

  describe 'Album#search' do
    it 'should search for the right albums' do
      albums = RSpotify::Album.search('AM')
      expect(albums)             .to be_an Array
      expect(albums.size)        .to eq 20
      expect(albums.first)       .to be_an RSpotify::Album
      expect(albums.map(&:name)) .to include('AM', 'Am I Wrong', 'A.M.', 'Melody AM')
    end
  end
end
