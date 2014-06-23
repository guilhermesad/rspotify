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

Directly access Spotify public data such as albums, tracks, artists and users:

```ruby
require 'rspotify'

artists = RSpotify::Artist.search('Arctic Monkeys')

arctic_monkeys = artists.first
arctic_monkeys.popularity      #=> 74
arctic_monkeys.genres          #=> ["Alternative Pop/Rock", "Indie", ...]
arctic_monkeys.top_tracks[:US] #=> (Track array)

albums = arctic_monkeys.albums
albums.first.name #=> "AM"

am = albums.first
am.release_date      #=> "2013-09-10"
am.images            #=> (Image array)
am.available_markets #=> ["AR", "BO", "BR", ...]

tracks = am.tracks
tracks.first.name #=> "Do I Wanna Know?"

do_i_wanna_know = tracks.first
do_i_wanna_know.duration_ms  #=> 272386
do_i_wanna_know.track_number #=> 1
do_i_wanna_know.preview_url  #=> "https://p.scdn.co/mp3-preview/<id>"

# You can search within other types too
albums = RSpotify::Album.search('The Wall')
tracks = RSpotify::Track.search('Thriller')
```

If you prefer, you can find them directly by id:

```ruby
arctic_monkeys = RSpotify::Artist.find('7Ln80lUS6He07XvHI8qqHH')
arctic_monkeys.external_urls['spotify'] #=> "https://open.spotify.com/artist/<id>"

am = RSpotify::Album.find('41vPD50kQ7JeamkxQW7Vuy')
am.album_type #=> "single"

do_i_wanna_know = RSpotify::Track.find('2UzMpPKPhbcC8RbsmuURAZ')
do_i_wanna_know.album #=> (Album object)

wizzler = RSpotify::User.find('wizzler')
wizzler.uri #=> "spotify:user:wizzler"

# Or find several objects at once:

ids = %w(2UzMpPKPhbcC8RbsmuURAZ 7Jzsc04YpkRwB1zeyM39wE)

my_tracks = RSpotify::Track.find(ids)
my_tracks.size #=> 2
```

Some data require authentication to be accessed, such as playlists. You can easily get your credentials [here](https://developer.spotify.com/my-applications).

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

RSpotify focuses on objects behaviour so you can forget the API and worry about your tracks, artists and so on.

It is possible to write things like `playlist.tracks.sort_by(&:popularity).last.album` without having to think what API calls you must do. RSpotify fills the gaps for you.

Full documentation can be found [here](http://rdoc.info/github/guilhermesad/rspotify/master/frames). (Will be complete in the next few days)

## Notes

This gem uses [client credentials](https://developer.spotify.com/web-api/authorization-guide/#client_credentials_flow) to authenticate your access. This means you can get all public data you want, but it's not possible to access private playlists or to create new ones. For that you would want to use [authorization code flow](https://developer.spotify.com/web-api/authorization-guide/#authorization_code_flow).

RSpotify focuses on simplicity of use and straight access to data, so the authorization code flow is not supported at the moment. If you really feel the need to use it, please leave a issue for it to be implemented.

## Contributing

1. Fork it ( https://github.com/guilhermesad/rspotify/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
