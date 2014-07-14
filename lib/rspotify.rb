require 'rspotify/connection'
require 'rspotify/oauth'
require 'rspotify/version'

module RSpotify
  autoload :Album,    'rspotify/album'
  autoload :Artist,   'rspotify/artist'
  autoload :Base,     'rspotify/base'
  autoload :Playlist, 'rspotify/playlist'
  autoload :Track,    'rspotify/track'
  autoload :User,     'rspotify/user'
end
