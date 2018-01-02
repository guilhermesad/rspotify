describe RSpotify::Recommendations do

  let(:client_id) { '5ac1cda2ad354aeaa1ad2693d33bb98c' }
  let(:client_secret) { '155fc038a85840679b55a1822ef36b9b' }

  before do
    authenticate_client
  end

  describe 'Recommendations::available_genre_seeds' do
    subject do
      VCR.use_cassette('recommendations:available_genre_seeds') do
        RSpotify::Recommendations.available_genre_seeds
      end
    end

    it 'retrieves a list of available genres seed parameter values' do
      available_genre_seeds = subject
      expect(available_genre_seeds.size) .to eq 126
      expect(available_genre_seeds)      .to include('black-metal', 'industrial', 'trip-hop')
    end
  end

  describe 'Recommendations::generate' do
    subject do
      VCR.use_cassette('recommendations_generate') do
        RSpotify::Recommendations.generate(
          limit: 20,
          seed_artists: ['0X380XXQSNBYuleKzav5UO', '6FXMGgJwohJLUSr5nVlf9X'], 
          seed_genres: ['electronic', 'industrial', 'trip-hop'], 
          market: 'US',
          min_danceability: 0.2, 
          target_valence: 0.6
        )
      end
    end 

    it 'generates a list of recommended tracks' do
      tracks = subject.tracks
      expect(tracks.count)                     .to eq(20)
      expect(tracks.map { |track| track.name }).to include('The Music Scene', 'Conditions of My Parole', 'Here Is No Why')
    end

    it 'generates a list of recommendation seeds' do
      seeds = subject.seeds
      expect(seeds.count)                                                         .to eq(5)
      expect(seeds.select { |seed| seed.type == 'ARTIST' }.map { |seed| seed.id }).to include('0X380XXQSNBYuleKzav5UO', '6FXMGgJwohJLUSr5nVlf9X')
    end
  end
end
