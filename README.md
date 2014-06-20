# RSpotify

This is a ruby wrapper for the [new Spotify Web API](https://developer.spotify.com/web-api), released in June 17, 2014.

## Installation

Add this line to your application's Gemfile:

    gem 'rspotify'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspotify

## Usage

This gem is pretty new and authentication has not yet been implemented. So far you can access public data such as albums, tracks and artists:

```ruby
require 'rspotify'

tracks = RSpotify::Track.search('Paranoid')

tracks.first.name       #=> "Paranoid"
tracks.first.popularity #=> 68

album = tracks.first.album
album.name   #=> "Paranoid (Remastered)"
album.images #=> (Image array)

artists = tracks.first.artists
artists.first.name #=> "Black Sabbath"
artists.first.uri  #=> "spotify:artist:5M52tdBnJaKSvOpJGz8mfZ"

# Find by id
artist = RSpotify::Artist.find('5K4W6rqBFWDnAN6FQUkS6x')
artist.genres #=> ["Alternative Rap", "East Coast Rap", "Hardcore Rap", "Hip Hop", "Midwest Rap", "Pop-Rap", "Rap"]

album = RSpotify::Album.find('0uZ8zQLHru4BiNTL2PQY91')
album.album_type #=> "single"
album.tracks     #=> (Track array)

track = RSpotify::Track.find('2qmxggATKFIeg68guRSG3r')
track.duration_ms #=> 270800
track.album       #=> (Album object)

user = RSpotify::User.find('wizzler')
user.external_urls["spotify"] #=> "https://open.spotify.com/user/wizzler"
```
More documentation will follow

## Contributing

1. Fork it ( https://github.com/guilhermesad/rspotify/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
