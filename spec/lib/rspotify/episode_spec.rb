describe RSpotify::Episode do
  describe 'Episode::find receiving id as a string' do
    before(:each) do
      @episode = VCR.use_cassette('episode:find:512ojhOuo1ktJprKbVcKyQ') do
        RSpotify::Episode.find('512ojhOuo1ktJprKbVcKyQ')
      end
    end

    it 'should find track with correct attributes' do
      expect(@episode.audio_preview_url)        .to eq "https://p.scdn.co/mp3-preview/566fcc94708f39bcddc09e4ce84a8e5db8f07d4d"
      expect(@episode.description)              .to start_with "En ny tysk bok granskar för första gången Tredje rikets drogberoende"
      expect(@episode.duration_ms)              .to eq 1_502_795
      expect(@episode.explicit)                 .to eq false
      expect(@episode.href)                     .to eq 'https://api.spotify.com/v1/episodes/512ojhOuo1ktJprKbVcKyQ'
      expect(@episode.html_description)         .to start_with "En ny tysk bok granskar för första gången Tredje rikets drogberoende"
      expect(@episode.id)                       .to eq '512ojhOuo1ktJprKbVcKyQ'
      expect(@episode.images.first["url"])      .to eq "https://i.scdn.co/image/de4a5f115ac6f6ca4cae4fb7aaf27bacac7a0b8a"
      expect(@episode.images.size)              .to eq 3
      expect(@episode.is_externally_hosted)     .to eq false
      expect(@episode.is_playable)              .to eq true
      expect(@episode.language)                 .to eq 'sv'
      expect(@episode.languages)                .to eq ["sv"]
      expect(@episode.name)                     .to eq 'Tredje rikets knarkande granskas'
      expect(@episode.release_date_precision)   .to eq 'day'
      expect(@episode.release_date)             .to eq '2015-10-01'
      expect(@episode.restrictions)             .to eq Hash.new
      expect(@episode.resume_point)             .to eq({"fully_played"=>false, "resume_position_ms"=>0})
      expect(@episode.uri)                      .to eq 'spotify:episode:512ojhOuo1ktJprKbVcKyQ'
    end

    it 'should find the episode with correct show' do
      show = @episode.show
      expect(show)      .to be_an RSpotify::Show
      expect(show.id)   .to eq '38bS44xjbVVZ3No3ByF1dJ'
      expect(show.name) .to eq 'Vetenskapsradion Historia'
    end

    it 'should find an episode which is available in the given market' do
      episode = VCR.use_cassette('episode:find:5NxzDE5TmviUV8te2eZjMP:market:ES') do
        RSpotify::Episode.find('5NxzDE5TmviUV8te2eZjMP', market: 'ES')
      end

      expect(episode.id).to eq '5NxzDE5TmviUV8te2eZjMP'
      expect(episode.is_playable). to eq true
    end

    it 'should not find an episode which is unavailable in the given market' do
      episode = VCR.use_cassette('episode:find:5NxzDE5TmviUV8te2eZjMP:market:KG') do
        RSpotify::Episode.find('5NxzDE5TmviUV8te2eZjMP', market: 'KG')
      end

      expect(episode.id).to eq '5NxzDE5TmviUV8te2eZjMP'
      expect(episode.is_playable). to eq false
    end
  end

  describe 'Episode::find receiving array of ids' do
    it 'should find the right episodes' do
      ids = ['512ojhOuo1ktJprKbVcKyQ']
      episodes = VCR.use_cassette('episode:find_array:512ojhOuo1ktJprKbVcKyQ') do
        RSpotify::Episode.find(ids)
      end
      expect(episodes)            .to be_an Array
      expect(episodes.size)       .to eq 1
      expect(episodes.first.name) .to eq 'Tredje rikets knarkande granskas'

      ids << '18RPZgmvEGKtEC2WMTHghd'
      episodes = VCR.use_cassette('episode:find_array:18RPZgmvEGKtEC2WMTHghd') do
        RSpotify::Episode.find(ids)
      end
      expect(episodes)            .to be_an Array
      expect(episodes.size)       .to eq 2
      expect(episodes.first.name) .to eq 'Tredje rikets knarkande granskas'
      expect(episodes.last.name)  .to eq 'Han upptäckte vikingastaden Birka'
    end
  end

  describe 'Episode::search' do
    it 'should search for the right episodes' do
      episodes = VCR.use_cassette('episode:search:Tredje rikets knarkande granskas') do
        RSpotify::Episode.search('Tredje rikets knarkande granskas')
      end

      expect(episodes)             .to be_an Array
      expect(episodes.size)        .to eq 20
      expect(episodes.total)       .to eq 527
      expect(episodes.first)       .to be_an RSpotify::Episode
      expect(episodes.map(&:name)) .to include('Tredje rikets knarkande granskas', '"Tre skadade i grovt våldsbrott i Lycksele"')
    end

    it 'should accept additional options' do
      episodes = VCR.use_cassette('episode:search:Tredje rikets knarkande granskas:limit:10') do
        RSpotify::Episode.search('Tredje rikets knarkande granskas', limit: 10)
      end
      expect(episodes.size)        .to eq 10
      expect(episodes.map(&:name)) .to include('Tredje rikets knarkande granskas', '14. Första världskrigets BÄSTA generaler ... och Conrad')

      episodes = VCR.use_cassette('episode:search:Tredje rikets knarkande granskas:offset:10') do
        RSpotify::Episode.search('Tredje rikets knarkande granskas', offset: 10)
      end
      expect(episodes.size)        .to eq 20
      expect(episodes.map(&:name)) .to include('GIIA-avsnitt 2: Stefan Kronanders avsnitt – tyska underrättelse-fuckups')

      episodes = VCR.use_cassette('episode:search:Tredje rikets knarkande granskas:limit:10:offset:10') do
        RSpotify::Episode.search('Tredje rikets knarkande granskas', limit: 10, offset: 10)
      end
      expect(episodes.size)        .to eq 10
      expect(episodes.map(&:name)) .to include('GIIA-avsnitt 2: Stefan Kronanders avsnitt – tyska underrättelse-fuckups')

      episodes = VCR.use_cassette('episode:search:Tredje rikets knarkande granskas:market:CA') do
        RSpotify::Episode.search('Tredje rikets knarkande granskas', market: 'CA')
        CA_episodes = episodes.map { |e| e.show.available_markets == 'CA'}
      end

      expect(CA_episodes.length).to eq(episodes.length)
    end
  end
end
