describe RSpotify::Category do

  # Keys generated specifically for the tests. Should be removed in the future
  let(:client_id) { '5ac1cda2ad354aeaa1ad2693d33bb98c' }
  let(:client_secret) { '155fc038a85840679b55a1822ef36b9b' }

  before do
    authenticate_client
  end

  describe 'Category::find' do
    it 'should find right category' do
      category = VCR.use_cassette('category:find:party') do
        RSpotify::Category.find('party')
      end

      expect(category.href)               .to eq 'https://api.spotify.com/v1/browse/categories/party'
      expect(category.icons.first['url']) .to eq 'https://datsnxq1rwndn.cloudfront.net/media/derived/party-274x274_73d1907a7371c3bb96a288390a96ee27_0_0_274_274.jpg'
      expect(category.id)                 .to eq 'party'
      expect(category.name)               .to eq 'Party'
    end

    it 'should find right category with additional attributes' do
      category = VCR.use_cassette('category:find:party:country:BR') do
        RSpotify::Category.find('party', country: 'BR')
      end
      expect(category.href)               .to eq 'https://api.spotify.com/v1/browse/categories/party'
      expect(category.name)               .to eq 'Party'

      category = VCR.use_cassette('category:find:party:locale:es_MX') do
        RSpotify::Category.find('party', locale: 'es_MX')
      end
      expect(category.href)               .to eq 'https://api.spotify.com/v1/browse/categories/party'
      expect(category.name)               .to eq 'Party'
    end
  end

  describe 'Category::list' do
    it 'should get the right categories' do
      categories = VCR.use_cassette('category:list') do
        RSpotify::Category.list
      end

      expect(categories.size)        .to eq 20
      expect(categories.map(&:name)) .to include('Top Lists', 'Country', 'Decades')
    end

    it 'should get the right categories with additional attributes' do
      categories = VCR.use_cassette('category:list:locale:es_MX:limit:10') do
        RSpotify::Category.list(locale: 'es_MX', limit: 10)
      end
      expect(categories.size)        .to eq 10
      expect(categories.map(&:name)) .to include('Dance', 'Pop', 'Chill')

      categories = VCR.use_cassette('category:list:country:BR') do
        RSpotify::Category.list(country: 'BR')
      end
      expect(categories.map(&:name)) .to include('Top Lists', 'Pop', 'Chill')
    end
  end

  describe 'Category#complete!' do
    let(:category) do
      RSpotify::Category.new({'id' => 'party'})
    end

    it 'should fetch the complete information correctly' do
      VCR.use_cassette('category:find:party') do
        category.complete!
      end
      expect(category.href)               .to eq 'https://api.spotify.com/v1/browse/categories/party'
      expect(category.icons.first['url']) .to eq 'https://datsnxq1rwndn.cloudfront.net/media/derived/party-274x274_73d1907a7371c3bb96a288390a96ee27_0_0_274_274.jpg'
      expect(category.name)               .to eq 'Party'
    end
  end

  describe 'Category#playlists' do
    let(:category) do
      # Get party category as a testing sample
      VCR.use_cassette('category:find:party') do
        RSpotify::Category.find('party')
      end
    end

    it 'should get correct playlists' do
      playlists = VCR.use_cassette('category:party:playlists') do
        category.playlists
      end

      expect(playlists)             .to be_an Array
      expect(playlists.size)        .to eq 20
      expect(playlists.first)       .to be_an RSpotify::Playlist
      expect(playlists.map(&:name)) .to include('Teen Party', 'Weekend Hangouts', 'Dance Party')
    end

    it 'should get correct playlists with additional options' do
      playlists = VCR.use_cassette('category:party:playlists:limit:10:offset:20') do
        category.playlists(limit: 10, offset: 20)
      end
      expect(playlists.size)        .to eq 10
      expect(playlists.map(&:name)) .to include('Indie Brunch', 'Hipster Funk', 'Party Hits')

      playlists = VCR.use_cassette('category:party:playlists:country:BR') do
        category.playlists(country: 'BR')
      end
      expect(playlists.map(&:name)) .to include('Lista VIP', 'Sexta', 'Modo Freestyle')
    end
  end
end
