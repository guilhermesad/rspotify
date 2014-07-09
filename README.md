# RSpotify

This is a ruby wrapper for the [new Spotify Web API](https://developer.spotify.com/web-api), released in June 17, 2014.

## Features

* [Full documentation](http://rdoc.info/github/guilhermesad/rspotify/master/frames)
* Full API Endpoint coverage
* OAuth and other authorization flows

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
arctic_monkeys.top_tracks(:US) #=> (Track array)

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

Find by id:

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

# Now you can access any public playlist and much more

playlist = RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX')
playlist.name               #=> "Movie Soundtrack Masterpieces"
playlist.description        #=> "Iconic soundtracks featured..."
playlist.followers['total'] #=> 13
playlist.tracks             #=> (Track array)

my_user = RSpotify::User.find("my_user")
my_playlists = my_user.playlists #=> (Playlist array)
```

RSpotify focuses on objects behaviour so you can forget the API and worry about your tracks, artists and so on.

It is possible to write things like `playlist.tracks.sort_by(&:popularity).last.album` without having to think what API calls must be done. RSpotify fills the gaps for you.

Check the [documentation](http://rdoc.info/github/guilhermesad/rspotify/master/frames) for all attributes and methods of albums, artists, etc.

## Rails + OAuth

You'll may want your application to access an user's Spotify account.

For instance, suppose you want your app to create playlists for the user based on his taste, or to add a feature that syncs user's playlists with some external app.

If so, just add the following to `config/initializers/omniauth.rb` (Remember to [get your credentials](https://developer.spotify.com/my-applications))

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, "<your_client_id>", "<your_client_secret>", scope: 'user-read-email playlist-modify'
end
```

You should replace the scope values for the ones your own app will require from the user. You can see the list of available scopes in [here](https://developer.spotify.com/web-api/using-scopes).

Then just make a link so the user can log in with his Spotify account:

```ruby
<%= link_to 'Sign in with Spotify', '/auth/spotify' %>
```

And create a route to receive the callback:

```ruby
# config/routes.rb

get '/auth/spotify/callback', to: 'users#spotify'
```

Remember you need to tell Spotify this address is white-listed. You can do this by adding it to the Redirect URIs list in your [application page](https://developer.spotify.com/my-applications). An example of Redirect URI would be http://localhost:3000/auth/spotify/callback.

Finally, create a new RSpotify User with the token received:

```ruby
class UsersController < ApplicationController
  def spotify
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    # Now you can access user's private data, create playlists and much more

    # Access private data (Check doc for all attributes)
    spotify_user.country #=> "US"
    spotify_user.email   #=> "example@email.com"

    # Create playlist in user's Spotify account
    playlist = spotify_user.create_playlist!('my-awesome-playlist')

    # Add tracks to a playlist in user's Spotify account
    tracks = RSpotify::Track.search('Know')
    playlist.add_tracks!(tracks)
    playlist.tracks.first.name #=> "Somebody That I Used To Know"
  end
end
```

**Note**: You might also like to add `RSpotify::authenticate("<your_client_id>", "<your_client_secret>")` to your `config/application.rb`. This will allow extra calls to be made.

## Notes

If you'd like to use OAuth outside rails, have a look [here](https://developer.spotify.com/web-api/authorization-guide/#authorization_code_flow) for the requests that need to be made. You should be able to pass the response to RSpotify::User.new just as well, and from there easily create playlists and more for your user.

## Contributing

1. Fork it ( https://github.com/guilhermesad/rspotify/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
