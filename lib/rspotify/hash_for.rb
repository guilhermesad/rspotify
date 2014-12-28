module RSpotify
  module HashFor
    private

    def hash_for(tracks, field)
      return nil unless tracks
      pairs = tracks.map do |track|
        key = track['track']['id']
        value = yield track[field] if track[field]
        [key, value]
      end
      Hash[pairs]
    end
  end
end
