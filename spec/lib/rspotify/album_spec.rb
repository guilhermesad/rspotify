describe RSpotify::Album do

  describe 'Album::find receiving id as a string' do

    before(:each) do
      # Get Arctic Monkeys's AM album as a testing sample
      @album = VCR.use_cassette('album:find:5bU1XKYxHhEwukllT20xtk') do
        RSpotify::Album.find('5bU1XKYxHhEwukllT20xtk')
      end
    end

    it 'should find album with correct attributes' do
      expect(@album.album_type)               .to eq      'album'
      expect(@album.available_markets)        .to include *%w(AD AT BE BG CA EE ES FR GR MC TW US)
      expect(@album.copyrights)               .to include ({'text' => '2013 Domino Recording Co Ltd', 'type' => 'C'})
      expect(@album.external_ids['upc'])      .to eq      '887828031795'
      expect(@album.external_urls['spotify']) .to eq      'https://open.spotify.com/album/5bU1XKYxHhEwukllT20xtk'
      expect(@album.genres)                   .to be_an   Array
      expect(@album.href)                     .to eq      'https://api.spotify.com/v1/albums/5bU1XKYxHhEwukllT20xtk'
      expect(@album.id)                       .to eq      '5bU1XKYxHhEwukllT20xtk'
      expect(@album.images)                   .to include ({'height' => 640, 'width' => 640, 'url' => 'https://i.scdn.co/image/4d9ec146e3a257b10634d9a413ef6cc3de325008'})
      expect(@album.name)                     .to eq      'AM'
      expect(@album.popularity)               .to be      > 0
      expect(@album.release_date)             .to eq      '2013-09-09'
      expect(@album.release_date_precision)   .to eq      'day'
      expect(@album.type)                     .to eq      'album'
      expect(@album.uri)                      .to eq      'spotify:album:5bU1XKYxHhEwukllT20xtk'
      expect(@album.total_tracks)             .to eq      12
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

  describe 'Album::find receiving array of ids' do
    it 'should find the right albums' do
      ids = ['2agWNCZl5Ts9W05mij8EPh']
      albums = VCR.use_cassette('album:find:2agWNCZl5Ts9W05mij8EPh') do
        RSpotify::Album.find(ids)
      end
      expect(albums)            .to be_an Array
      expect(albums.size)       .to eq 1
      expect(albums.first.name) .to eq 'The Next Day Extra'

      ids << '3JquYMWj5wrzuZCNAvOYN9'
      albums = VCR.use_cassette('album:find:3JquYMWj5wrzuZCNAvOYN9') do
        RSpotify::Album.find(ids)
      end
      expect(albums)            .to be_an Array
      expect(albums.size)       .to eq 2
      expect(albums.first.name) .to eq 'The Next Day Extra'
      expect(albums.last.name)  .to eq 'A Beard Of Stars (Deluxe Edition)'
    end
  end

  describe 'Album::new_releases' do
    # Keys generated specifically for the tests. Should be removed in the future
    let(:client_id) { '5ac1cda2ad354aeaa1ad2693d33bb98c' }
    let(:client_secret) { '155fc038a85840679b55a1822ef36b9b' }

    before(:each) do
    VCR.use_cassette('authenticate:client') do
        RSpotify.authenticate(client_id, client_secret)
      end
    end

    it 'should find the appropriate new releases' do
      albums = VCR.use_cassette('album:new_releases') do
        RSpotify::Album.new_releases
      end
      expect(albums.size)        .to eq 20
      expect(albums.map(&:name)) .to include('A13', 'Singles', 'Magic')
    end

    it 'should accept additional options' do
      albums = VCR.use_cassette('album:new_releases:limit:10:offset:10') do
        RSpotify::Album.new_releases(limit: 10, offset: 10)
      end
      expect(albums.size)        .to eq 10
      expect(albums.map(&:name)) .to include('Recess', 'Atlas', 'Magic')

      albums = VCR.use_cassette('album:new_releases:country:ES') do
        RSpotify::Album.new_releases(country: 'ES')
      end
      expect(albums.size)        .to eq 20
      expect(albums.map(&:name)) .to include('Me Olvide de Vivir', 'Amor Futuro')
    end
  end

  describe 'Album::search' do
    it 'should search for the right albums' do
      albums = VCR.use_cassette('album:search:AM') do
        RSpotify::Album.search('AM')
      end
      expect(albums)             .to be_an Array
      expect(albums.size)        .to eq 20
      expect(albums.total)       .to eq 8672
      expect(albums.first)       .to be_an RSpotify::Album
      expect(albums.map(&:name)) .to include('AM', 'Am I Wrong', 'A.M.', 'Melody AM')
    end

    it 'should accept additional options' do
      albums = VCR.use_cassette('album:search:AM:limit:10') do
        RSpotify::Album.search('AM', limit: 10)
      end
      expect(albums.size)        .to eq 10
      expect(albums.map(&:name)) .to include('AM', 'Am I Wrong')

      albums = VCR.use_cassette('album:search:AM:offset:10') do
        RSpotify::Album.search('AM', offset: 10)
      end
      expect(albums.size)        .to eq 20
      expect(albums.map(&:name)) .to include('Melody AM', 'I Am')

      albums = VCR.use_cassette('album:search:AM:offset:10:limit:10') do
        RSpotify::Album.search('AM', limit: 10, offset: 10)
      end
      expect(albums.size)        .to eq 10
      expect(albums.map(&:name)) .to include('Melody AM')

      albums = VCR.use_cassette('album:search:AM:market:ES') do
        RSpotify::Album.search('AM', market: 'ES')
      end
      ES_albums = albums.select { |a| a.available_markets.include?('ES') }
      expect(ES_albums.length).to eq(albums.length)
    end
  end

  describe '.embed' do
    before(:each) do
      @album = VCR.use_cassette('album:find:5bU1XKYxHhEwukllT20xtk') do
        RSpotify::Album.find('5bU1XKYxHhEwukllT20xtk')
      end
    end

    it 'returns the correct iframe' do
      expect(@album.embed).to eq '<iframe src="https://embed.spotify.com/?uri=spotify:album:5bU1XKYxHhEwukllT20xtk" width="300" height="380" frameborder="0" allowtransparency="true"> </iframe>'
    end

    context 'with a coverart view' do
      it 'returns the correct iframe' do
        expect(@album.embed(view: :coverart)).to eq '<iframe src="https://embed.spotify.com/?uri=spotify:album:5bU1XKYxHhEwukllT20xtk&view=coverart" width="300" height="380" frameborder="0" allowtransparency="true"> </iframe>'
      end
    end

    context 'with different width & height' do
      it 'returns the correct iframe' do
        expect(@album.embed(width: 800)).to eq '<iframe src="https://embed.spotify.com/?uri=spotify:album:5bU1XKYxHhEwukllT20xtk" width="800" height="380" frameborder="0" allowtransparency="true"> </iframe>'
      end

      it 'returns the correct iframe' do
        expect(@album.embed(height: 100)).to eq '<iframe src="https://embed.spotify.com/?uri=spotify:album:5bU1XKYxHhEwukllT20xtk" width="300" height="100" frameborder="0" allowtransparency="true"> </iframe>'
      end
    end

    context 'with frameborder' do
      it 'returns the correct iframe' do
        expect(@album.embed(frameborder: 10)).to eq '<iframe src="https://embed.spotify.com/?uri=spotify:album:5bU1XKYxHhEwukllT20xtk" width="300" height="380" frameborder="10" allowtransparency="true"> </iframe>'
      end
    end

    context 'with allowtransparency' do
      it 'returns the correct iframe' do
        expect(@album.embed(allowtransparency: false)).to eq '<iframe src="https://embed.spotify.com/?uri=spotify:album:5bU1XKYxHhEwukllT20xtk" width="300" height="380" frameborder="0" allowtransparency="false"> </iframe>'
      end
    end

    context 'with theme' do
      it 'returns the correct iframe' do
        expect(@album.embed(theme: :white)).to eq '<iframe src="https://embed.spotify.com/?uri=spotify:album:5bU1XKYxHhEwukllT20xtk&theme=white" width="300" height="380" frameborder="0" allowtransparency="true"> </iframe>'
      end
    end
  end
end

