describe RSpotify::Artist do

  describe 'Artist::find receiving id as a string' do

    before(:each) do
      # Get Arctic Monkeys as a testing sample
      @artist = VCR.use_cassette('artist:find:7Ln80lUS6He07XvHI8qqHH') do 
        RSpotify::Artist.find('7Ln80lUS6He07XvHI8qqHH')
      end
    end

    it 'should find artist with correct attributes' do
      expect(@artist.external_urls['spotify']) .to eq      'https://open.spotify.com/artist/7Ln80lUS6He07XvHI8qqHH'
      expect(@artist.followers['total'])       .to be      > 0
      expect(@artist.genres)                   .to be_an   Array
      expect(@artist.href)                     .to eq      'https://api.spotify.com/v1/artists/7Ln80lUS6He07XvHI8qqHH'
      expect(@artist.id)                       .to eq      '7Ln80lUS6He07XvHI8qqHH'
      expect(@artist.images)                   .to include ({'height' => 1333, 'width' => 1000, 'url' => 'https://i.scdn.co/image/fa2e9ca1a27695ae7f8013350d9a53e11d523ece'})
      expect(@artist.name)                     .to eq      'Arctic Monkeys'
      expect(@artist.popularity)               .to be      > 0
      expect(@artist.type)                     .to eq      'artist'
      expect(@artist.uri)                      .to eq      'spotify:artist:7Ln80lUS6He07XvHI8qqHH'
    end

    it 'should find artist with correct albums' do
      albums = VCR.use_cassette('artist:7Ln80lUS6He07XvHI8qqHH:albums:limit:20:offset:0') do 
        @artist.albums
      end
      expect(albums)             .to be_an Array
      expect(albums.size)        .to eq 20
      expect(albums.first)       .to be_an RSpotify::Album
      expect(albums.map(&:name)) .to include('AM', 'Suck It and See', 'Suck It and See Sampler' , 'Humbug')
    end

    it 'should find artist with correct top tracks' do
      top_tracks = VCR.use_cassette('artist:7Ln80lUS6He07XvHI8qqHH:top_tracks:US') do 
        @artist.top_tracks(:US)
      end
      expect(top_tracks)             .to be_an Array
      expect(top_tracks.size)        .to eq 10
      expect(top_tracks.first)       .to be_an RSpotify::Track
      expect(top_tracks.map(&:name)) .to include('Do I Wanna Know?', 'R U Mine?', 'Arabella', 'Knee Socks')
    end

    it 'should find artist with correct related artists' do
      related_artists = VCR.use_cassette('artist:7Ln80lUS6He07XvHI8qqHH:related_artists') do 
        @artist.related_artists
      end
      expect(related_artists)             .to be_an Array
      expect(related_artists.size)        .to eq 20
      expect(related_artists.first)       .to be_an RSpotify::Artist
      expect(related_artists.map(&:name)) .to include('Miles Kane', 'We Are Scientists', 'Razorlight')
    end
  end

  describe 'Artist::find receiving array of ids' do
    it 'should find the right artists' do
      ids = ['0oSGxfWSnnOXhD2fKuz2Gy']
      artists = VCR.use_cassette('artist:find:0oSGxfWSnnOXhD2fKuz2Gy') do 
        RSpotify::Artist.find(ids)
      end
      expect(artists)            .to be_an Array
      expect(artists.size)       .to eq 1
      expect(artists.first.name) .to eq 'David Bowie'

      ids << '3dBVyJ7JuOMt4GE9607Qin'
      artists = VCR.use_cassette('artist:find:3dBVyJ7JuOMt4GE9607Qin') do 
        RSpotify::Artist.find(ids)
      end
      expect(artists)            .to be_an Array
      expect(artists.size)       .to eq 2
      expect(artists.first.name) .to eq 'David Bowie'
      expect(artists.last.name)  .to eq 'T. Rex'
    end
  end

  describe 'Artist::search' do
    it 'should search for the right artists' do
      artists = VCR.use_cassette('artist:search:Arctic') do 
        RSpotify::Artist.search('Arctic')
      end
      expect(artists)             .to be_an Array
      expect(artists.size)        .to eq 20
      expect(artists.total)       .to eq 127
      expect(artists.first)       .to be_an RSpotify::Artist
      expect(artists.map(&:name)) .to include('Arctic Monkeys', 'Arctic Lake')
    end

    it 'should accept additional options' do
      artists = VCR.use_cassette('artist:search:Arctic:limit:10') do 
        RSpotify::Artist.search('Arctic', limit: 10)
      end
      expect(artists.size)        .to eq 10
      expect(artists.map(&:name)) .to include('Arctic Monkeys', 'Arctic')

      artists = VCR.use_cassette('artist:search:Arctic:offset:10') do 
        RSpotify::Artist.search('Arctic', offset: 10)
      end
      expect(artists.size)        .to eq 20
      expect(artists.map(&:name)) .to include('Arctic Flame', 'Arctic Night')

      artists = VCR.use_cassette('artist:search:Arctic:offset:10:limit:10') do 
        RSpotify::Artist.search('Arctic', limit: 10, offset: 10)
      end
      expect(artists.size)        .to eq 10
      expect(artists.map(&:name)) .to include('Arctic')

      artists = VCR.use_cassette('artist:search:Arctic:market:ES') do
        RSpotify::Artist.search('Arctic', market: 'ES')
      end
      expect(artists.size)        .to eq 20
      expect(artists.map(&:name)) .to include('Arctic Lake')
    end
    
    
    context 'when token is expired' do
      it 'should resend token with new token' do
        auth_response = {'access_token': 'token'}.to_json
        new_auth_response = {'access_token': 'new_token'}.to_json
        
        expect(RestClient).to receive(:post)
          .and_return(auth_response, new_auth_response)
        
        RSpotify.authenticate('client_id', 'client_secret')
        
        # When token is expired it returns 401 
        expect(RestClient).to receive(:send).and_raise(RestClient::Unauthorized)
          .with(anything, anything, {"Authorization" => "Bearer token"})
        
        retry_response = {
          "artists" => { "items" => [] }
        }.to_json
        expect(RestClient).to receive(:send).and_return(retry_response)
          .with(anything, anything, {"Authorization"  => "Bearer new_token"})
        
        artists = VCR.use_cassette('artist:search:Arctic') do 
          RSpotify::Artist.search('Arctic')
        end
      end
    end
  end
end
