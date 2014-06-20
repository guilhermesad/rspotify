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

Directly access public data such as albums, tracks, artists and users:

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

Some data require authentication to be accessed, such as playlists. You can easily get your credentials [here](https://developer.spotify.com/my-applications)

Then just copy and paste them like so:

```ruby
RSpotify.authenticate("<your_client_id>", "<your_client_secret>")

# Now you can access any public playlist and much more!

playlist = RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX')
playlist.name               #=> "Movie Soundtrack Masterpieces"
playlist.description        #=> "Iconic soundtracks featured..."
playlist.followers['total'] #=> 13
playlist.tracks             #=> (Track array)

my_user = RSpotify::User.find("my_user")
my_playlists = my_user.playlists #=> (Playlist array)
```

More documentation will follow

## Contributing

1. Fork it ( https://github.com/guilhermesad/rspotify/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
