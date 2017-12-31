describe RSpotify do
  describe '.client_token' do
    it 'should return the client_token' do
      authenticate_client

      expect(RSpotify.client_token).to eq(AuthenticationHelper::CLIENT_SECRET)
    end
  end
end
