describe RSpotify::Show do
  describe 'Show::find receiving id as a string' do

    before(:each) do
      @show = VCR.use_cassette('show:find:5CfCWKI5pZ28U0uOzXkDHe') do
        RSpotify::Show.find('5CfCWKI5pZ28U0uOzXkDHe')
      end
    end

    it 'should find show with correct attributes' do
      expect(@show.available_markets)        .to be_an   Array
      expect(@show.copyrights)               .to eq []
      expect(@show.external_urls['spotify']) .to eq      'https://open.spotify.com/show/5CfCWKI5pZ28U0uOzXkDHe'
      expect(@show.description)              .to eq      'Candid conversations with entrepreneurs, artists, athletes, visionaries of all kinds—about their successes, and their failures, and what they learned from both. Hosted by Alex Blumberg, from Gimlet Media.'
      expect(@show.explicit)                 .to eq      true
      expect(@show.html_description)         .to eq      '<p>Candid conversations with entrepreneurs, artists, athletes, visionaries of all kinds—about their successes, and their failures, and what they learned from both. Hosted by Alex Blumberg, from Gimlet Media.</p>'
      expect(@show.href)                     .to eq      'https://api.spotify.com/v1/shows/5CfCWKI5pZ28U0uOzXkDHe'
      expect(@show.id)                       .to eq      '5CfCWKI5pZ28U0uOzXkDHe'
      expect(@show.images)                   .to include ({'height' => 640, 'width' => 640, 'url' => 'https://i.scdn.co/image/ab6765630000ba8a9d827f6e7e311b5947cce059'})
      expect(@show.is_externally_hosted)     .to eq      false
      expect(@show.languages)                .to eq      ["en"]
      expect(@show.media_type)               .to eq      "audio"
      expect(@show.name)                     .to eq      "Without Fail"
      expect(@show.publisher)                .to eq      "Gimlet"
      expect(@show.type)                     .to eq      'show'
      expect(@show.uri)                      .to eq      'spotify:show:5CfCWKI5pZ28U0uOzXkDHe'
    end

    it 'should find show with correct episodes' do
      episodes = @show.episodes
      expect(episodes)             .to be_an Array
      expect(episodes.size)        .to eq 20
      expect(episodes.first)       .to be_an RSpotify::Episode
      expect(episodes.map(&:name)) .to include("Introducing Michelle Obama and Her Mentees")
    end
  end

  describe 'Show::find receiving array of ids' do
    it 'should find the right shows' do
      ids = ['5CfCWKI5pZ28U0uOzXkDHe']
      shows = VCR.use_cassette('show:find_many:5CfCWKI5pZ28U0uOzXkDHe') do
        RSpotify::Show.find(ids)
      end
      expect(shows)             .to be_an Array
      expect(shows.size)        .to eq 1
      expect(shows.first)       .to be_an RSpotify::Show
      expect(shows.map(&:name)) .to include("Without Fail")

      ids << '5as3aKmN2k11yfDDDSrvaZ'
      shows = VCR.use_cassette('show:find_many:5CfCWKI5pZ28U0uOzXkDHe:5as3aKmN2k11yfDDDSrvaZ') do
        RSpotify::Show.find(ids)
      end
      expect(shows)             .to be_an Array
      expect(shows.size)        .to eq 2
      expect(shows.first)       .to be_an RSpotify::Show
      expect(shows.map(&:name)) .to include("Giant Bombcast")
    end

    it 'should find shows available in the given market' do
      ids = ['5CfCWKI5pZ28U0uOzXkDHe', '5as3aKmN2k11yfDDDSrvaZ']
      shows = VCR.use_cassette('show:find_many:5CfCWKI5pZ28U0uOzXkDHe:5as3aKmN2k11yfDDDSrvaZ:market:CA') do
        RSpotify::Show.find(ids, market: 'CA')
      end

      expect(shows)             .to be_an Array
      expect(shows.map(&:id))   .to include '5CfCWKI5pZ28U0uOzXkDHe'
    end
  end

  describe 'Show::search' do
    it 'should search for the right shows' do
      shows = VCR.use_cassette('show:search:without fail') do
        RSpotify::Show.search('Without Fail')
      end
      expect(shows)             .to be_an Array
      expect(shows.size)        .to eq 20
      expect(shows.total)       .to eq 233
      expect(shows.first)       .to be_an RSpotify::Show
      expect(shows.map(&:name)) .to include('Without Fail', 'Teach Without a Burden')
    end

    it 'should accept additional options' do
      shows = VCR.use_cassette('show:search:without fail:limit:10') do
        RSpotify::Show.search('Without Fail', limit: 10)
      end
      expect(shows.size)        .to eq 10
      expect(shows.map(&:name)) .to include('Without Fail', 'Teach Without a Burden')

      shows = VCR.use_cassette('show:search:without fail:offset:10') do
        RSpotify::Show.search('Without Fail', offset: 10)
      end
      expect(shows.size)        .to eq 20
      expect(shows.map(&:name)) .to include('Weight Loss Mindset', 'Two In The Think Tank')

      shows = VCR.use_cassette('show:search:without fail:offset:10:limit:10') do
        RSpotify::Show.search('Without Fail', limit: 10, offset: 10)
      end
      expect(shows.size)        .to eq 10
      expect(shows.map(&:name)) .to include('Two In The Think Tank')

      shows = VCR.use_cassette('show:search:without fail:market:ES') do
        RSpotify::Show.search('Without Fail', market: 'ES')
      end
      ES_shows = shows.select { |a| a.available_markets.include?('ES') }
      expect(ES_shows.length).to eq(shows.length)
    end
  end

  describe '#episodes' do
    it 'should fetch more episodes' do
      show = VCR.use_cassette('show:find:5CfCWKI5pZ28U0uOzXkDHe') do
        RSpotify::Show.find('5CfCWKI5pZ28U0uOzXkDHe')
      end

      episodes = VCR.use_cassette('show:find:5CfCWKI5pZ28U0uOzXkDHe:episodes') do
        show.episodes(offset: 20, limit: 20)
      end

      expect(episodes)            .to be_an Array
      expect(episodes.size)       .to eq 20
      expect(episodes.first.name) .to eq 'Being an A$$hole: The Final Frontier for Women on the Screen'
      expect(episodes.first.id)   .to eq '0DD6d3lmUjkIHzC13Z6fbs'
    end

    it "should find episodes available in the given market" do
      show = VCR.use_cassette('show:find:5CfCWKI5pZ28U0uOzXkDHe') do
        RSpotify::Show.find('5CfCWKI5pZ28U0uOzXkDHe')
      end

      episodes = VCR.use_cassette('show:find:5CfCWKI5pZ28U0uOzXkDHe:episodes:market:ES') do
        show.episodes(offset: 20, limit: 20, market: 'ES')
      end

      expect(episodes.first.name) .to eq 'Being an A$$hole: The Final Frontier for Women on the Screen'
      expect(episodes.first.id)   .to eq '0DD6d3lmUjkIHzC13Z6fbs'
    end
  end
end