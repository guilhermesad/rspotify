describe RSpotify::AudioAnalysis do
  
  let(:client_id) { '5ac1cda2ad354aeaa1ad2693d33bb98c' }
  let(:client_secret) { '155fc038a85840679b55a1822ef36b9b' }

  before do
    authenticate_client
  end

  describe 'AudioAnalysis::find receiving id as a string' do

    before(:each) do
      # Get Arctic Monkeys's "Do I Wanna Know?" track as a testing sample
      @audio_analysis = VCR.use_cassette('audio_analysis:find:3jfr0TF6DQcOLat8gGn7E2') do
        RSpotify::AudioAnalysis.find('3jfr0TF6DQcOLat8gGn7E2')
      end
    end

    it 'should return a response containing an analysis meta data object' do
      meta_data = @audio_analysis.meta
      expect(meta_data)             .to be_an RSpotify::AudioAnalysisMeta
    end
    
    it 'should return a response containing a track analysis object' do
        track_data = @audio_analysis.track
        expect(track_data)          .to be_an RSpotify::AudioAnalysisTrack
    end

    it 'should return a response containing an array of bar objects' do
      bars = @audio_analysis.bars
      expect(bars)                  .to be_an Array
    end

    it 'should return a response containing an array of beat objects' do
      beats = @audio_analysis.beats
      expect(beats)                 .to be_an Array
    end

    it 'should return a response containing an array of section objects' do
      sections = @audio_analysis.sections
      expect(sections)              .to be_an Array
    end

    it 'should return a response containing an array of segment objects' do
      segments = @audio_analysis.segments
      expect(segments)              .to be_an Array
    end

    it 'should return a response containing an array of tatum objects' do
      tatums = @audio_analysis.tatums
      expect(tatums)                .to be_an Array
    end
  end
end