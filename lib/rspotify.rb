require 'rspotify/connection'
require 'rspotify/version'

module RSpotify
  autoload :Album,              'rspotify/album'
  autoload :Artist,             'rspotify/artist'
  autoload :AudioFeatures,      'rspotify/audio_features'
  autoload :Base,               'rspotify/base'
  autoload :Category,           'rspotify/category'
  autoload :TrackLink,          'rspotify/track_link'
  autoload :Playlist,           'rspotify/playlist'
  autoload :Recommendations,    'rspotify/recommendations'
  autoload :RecommendationSeed, 'rspotify/recommendation_seed'
  autoload :Track,              'rspotify/track'
  autoload :User,               'rspotify/user'
end
