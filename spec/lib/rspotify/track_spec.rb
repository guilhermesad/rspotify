describe RSpotify::Track do

  describe 'valid track' do
    
    before(:each) do
      # Get Arctic Monkeys's "Do I Wanna Know?" track as a testing sample
      @track = RSpotify::Track.find('3jfr0TF6DQcOLat8gGn7E2')
    end

    it 'should have correct attributes' do
      expect(@track.available_markets)        .to include *%w(AD AT BE BG CA EE ES FR GR MC TW US)
      expect(@track.disc_number)              .to eq 1
      expect(@track.duration_ms)              .to eq 272394
      expect(@track.explicit)                 .to eq false
      expect(@track.external_ids['isrc'])     .to eq 'GBCEL1300362'
      expect(@track.external_urls['spotify']) .to eq 'https://open.spotify.com/track/3jfr0TF6DQcOLat8gGn7E2'
      expect(@track.href)                     .to eq 'https://api.spotify.com/v1/tracks/3jfr0TF6DQcOLat8gGn7E2'
      expect(@track.id)                       .to eq '3jfr0TF6DQcOLat8gGn7E2'
      expect(@track.name)                     .to eq 'Do I Wanna Know?'
      expect(@track.popularity)               .to be > 0
      expect(@track.preview_url)              .to eq 'https://p.scdn.co/mp3-preview/c181f36e2fe0fb41885cb83a8fe9f76480952701'
      expect(@track.track_number)             .to eq 1
      expect(@track.type)                     .to eq 'track'
      expect(@track.uri)                      .to eq 'spotify:track:3jfr0TF6DQcOLat8gGn7E2'
    end

    it 'should belong to correct artists' do
      artists = @track.artists
      expect(artists)      .to be_an Array
      expect(artists.size) .to eq 1
  
      artist = artists.first
      expect(artist)      .to be_an RSpotify::Artist
      expect(artist.id)   .to eq '7Ln80lUS6He07XvHI8qqHH'
      expect(artist.name) .to eq 'Arctic Monkeys'
    end

    it 'should belong to correct album' do
      album = @track.album
      expect(album)      .to be_an RSpotify::Album
      expect(album.id)   .to eq '5bU1XKYxHhEwukllT20xtk'
      expect(album.name) .to eq 'AM'
    end

  end
end
