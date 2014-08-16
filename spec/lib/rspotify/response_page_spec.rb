describe RSpotify::ResponsePage do 

  describe "tracks ResponsePage from playlist" do

    before(:each) do 
      @playlist = VCR.use_cassette('playlist:find:spilliton:71LUUNEsUJTmF36U077MJ7') do 
        authenticate_test_account
        RSpotify::Playlist.find('spilliton', '71LUUNEsUJTmF36U077MJ7')
      end
      @tracks = @playlist.tracks
    end

    it "should have correct attributes" do 
      expect(@tracks.item_class)  .to eq RSpotify::Track
      expect(@tracks.length) .to eq 100
      expect(@tracks.total) .to eq 102
      expect(@tracks.limit) .to eq 100
      expect(@tracks.offset) .to eq 0
      expect(@tracks.previous) .to eq false
      expect(@tracks.next) .to eq "users/spilliton/playlists/71LUUNEsUJTmF36U077MJ7/tracks?offset=100&limit=100"
      expect(@tracks.previous_page) .to eq nil
    end 

    it "should correctly fetch next_page" do 
      next_page = VCR.use_cassette('playlist:71LUUNEsUJTmF36U077MJ7:next_page') do 
        authenticate_test_account
        @tracks.next_page
      end
      expect(next_page.item_class)  .to eq RSpotify::Track
      expect(next_page.length) .to eq 2
      expect(next_page.total) .to eq 102
      expect(next_page.limit) .to eq 100
      expect(next_page.offset) .to eq 100
      expect(next_page.previous) .to eq "users/spilliton/playlists/71LUUNEsUJTmF36U077MJ7/tracks?offset=0&limit=100"
      expect(next_page.next) .to eq false
      expect(next_page.previous_page) .to eq @tracks
      expect(next_page.next_page) .to eq nil
    end

  end

end

