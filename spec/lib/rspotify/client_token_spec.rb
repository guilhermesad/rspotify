describe RSpotify do
  describe '.client_token' do
    it 'should return the client_token' do
      client_id = '5ac1cda2ad354aeaa1ad2693d33bb98c'
      client_secret = '155fc038a85840679b55a1822ef36b9b'
      VCR.use_cassette('authenticate:client') do
        RSpotify.authenticate(client_id, client_secret)
      end

      expect(RSpotify.client_token).to eq(
        'BQBj_AiSFlKCkNIMbCWEYjuJLl6n76QmVsHU6MGDgTUBLZqNiKZ4ALs6Kvm6ulbsW9O81JDdIHyXBndXyhUOxg'
      )
    end
  end
end
