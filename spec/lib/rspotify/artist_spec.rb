describe RSpotify::Artist do

  describe 'Artist::find receiving id as a string' do

    before(:each) do
      # Get Arctic Monkeys as a testing sample
      @artist = RSpotify::Artist.find('7Ln80lUS6He07XvHI8qqHH')
    end

    it 'should find artist with correct attributes' do
      expect(@artist.external_urls['spotify']) .to eq      'https://open.spotify.com/artist/7Ln80lUS6He07XvHI8qqHH'
      expect(@artist.genres)                   .to include 'Alternative Pop/Rock', 'Alternative/Indie Rock', 'Indie', 'Indie Rock', 'Pop/Rock'
      expect(@artist.href)                     .to eq      'https://api.spotify.com/v1/artists/7Ln80lUS6He07XvHI8qqHH'
      expect(@artist.id)                       .to eq      '7Ln80lUS6He07XvHI8qqHH'
      expect(@artist.images)                   .to include ({'height' => 1333, 'width' => 1000, 'url' => 'https://i.scdn.co/image/fa2e9ca1a27695ae7f8013350d9a53e11d523ece'})
      expect(@artist.name)                     .to eq      'Arctic Monkeys'
      expect(@artist.popularity)               .to be      > 0
      expect(@artist.type)                     .to eq      'artist'
      expect(@artist.uri)                      .to eq      'spotify:artist:7Ln80lUS6He07XvHI8qqHH'
    end

    it 'should find artist with correct albums' do
      albums = @artist.albums
      expect(albums)             .to be_an Array
      expect(albums.size)        .to eq 20
      expect(albums.first)       .to be_an RSpotify::Album
      expect(albums.map(&:name)) .to include('AM', 'Suck It and See', 'Suck It and See Sampler' , 'Humbug')
    end

    it 'should find artist with correct top tracks' do
      top_tracks = @artist.top_tracks(:US)
      expect(top_tracks)             .to be_an Array
      expect(top_tracks.size)        .to eq 10
      expect(top_tracks.first)       .to be_an RSpotify::Track
      expect(top_tracks.map(&:name)) .to include('Do I Wanna Know?', 'R U Mine?', 'Arabella', 'Knee Socks')
    end

    it 'should find artist with correct related artists' do
      related_artists = @artist.related_artists
      expect(related_artists)             .to be_an Array
      expect(related_artists.size)        .to eq 20
      expect(related_artists.first)       .to be_an RSpotify::Artist
      expect(related_artists.map(&:name)) .to include('Miles Kane', 'We Are Scientists', 'Razorlight')
    end
  end

  describe 'Artist::find receiving array of ids' do
    it 'should find the right artists' do
      ids = ['0oSGxfWSnnOXhD2fKuz2Gy']
      artists = RSpotify::Artist.find(ids)
      expect(artists)            .to be_an Array
      expect(artists.size)       .to eq 1
      expect(artists.first.name) .to eq 'David Bowie'

      ids << '3dBVyJ7JuOMt4GE9607Qin'
      artists = RSpotify::Artist.find(ids)
      expect(artists)            .to be_an Array
      expect(artists.size)       .to eq 2
      expect(artists.first.name) .to eq 'David Bowie'
      expect(artists.last.name)  .to eq 'T. Rex'
    end
  end

  describe 'Artist::search' do
    it 'should search for the right artists' do
      artists = RSpotify::Artist.search('Arctic')
      expect(artists)             .to be_an Array
      expect(artists.size)        .to eq 20
      expect(artists.first)       .to be_an RSpotify::Artist
      expect(artists.map(&:name)) .to include('Arctic Monkeys', 'Arctic', 'Arctic Warbler', 'Arctic Express')
    end

    it 'should accept additional options' do
      artists = RSpotify::Artist.search('Arctic', limit: 10)
      expect(artists.size)        .to eq 10
      expect(artists.map(&:name)) .to include('Arctic Monkeys', 'Arctic')

      artists = RSpotify::Artist.search('Arctic', offset: 10)
      expect(artists.size)        .to eq 20
      expect(artists.map(&:name)) .to include('Arctic Light', 'Arctic Night')

      artists = RSpotify::Artist.search('Arctic', limit: 10, offset: 10)
      expect(artists.size)        .to eq 10
      expect(artists.map(&:name)) .to include('Arctic Light')
    end
  end
end
