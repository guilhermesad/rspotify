# RSpotify

[![Gem Version](https://badge.fury.io/rb/rspotify.svg)](http://badge.fury.io/rb/rspotify)
[![Build Status](https://travis-ci.org/guilhermesad/rspotify.svg?branch=master)](https://travis-ci.org/guilhermesad/rspotify)

This is a ruby wrapper for the [Spotify Web API](https://developer.spotify.com/web-api).

## Features

* [Full documentation](http://www.rubydoc.info/github/guilhermesad/rspotify/master)
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

RSpotify was designed with usability as its primary goal, so that you can forget the API and intuitively interact with your playlists, favorite artists, users and so on.

You can write things like `my_playlist.tracks.sort_by(&:popularity).last.album` without having to think which API calls must be done. RSpotify fills the gaps for you.

Below are some basic usage examples. Check the [documentation](http://rdoc.info/github/guilhermesad/rspotify/master/frames) for the complete reference.

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

playlists = RSpotify::Playlist.search('Indie')
playlists.first.name #=> "The Indie Mix"

# You can search within other types too
albums = RSpotify::Album.search('The Wall')
tracks = RSpotify::Track.search('Thriller')
```

Find by id:

```ruby
arctic_monkeys = RSpotify::Artist.find('7Ln80lUS6He07XvHI8qqHH')
arctic_monkeys.related_artists #=> (Artist array)

am = RSpotify::Album.find('41vPD50kQ7JeamkxQW7Vuy')
am.album_type #=> "single"

do_i_wanna_know = RSpotify::Track.find('2UzMpPKPhbcC8RbsmuURAZ')
do_i_wanna_know.album #=> (Album object)

me = RSpotify::User.find('guilhermesad')
me.uri #=> "spotify:user:guilhermesad"

# Or find several objects at once:

ids = %w(2UzMpPKPhbcC8RbsmuURAZ 7Jzsc04YpkRwB1zeyM39wE)

my_tracks = RSpotify::Track.find(ids)
my_tracks.size #=> 2
```

Some data require authentication to be accessed, such as playlists' details. You can easily get your credentials [here](https://developer.spotify.com/my-applications).

Then just copy and paste them like so:

```ruby
RSpotify.authenticate("<your_client_id>", "<your_client_secret>")

# Now you can access playlists in detail, browse featured content and more

me = RSpotify::User.find('guilhermesad')
me.playlists #=> (Playlist array)

# Find by id
playlist = RSpotify::Playlist.find('guilhermesad', '1Xi8mgiuHHPLQYOw2Q16xv')
playlist.name               #=> "d33p"
playlist.description        #=> "d33p h0uz"
playlist.followers['total'] #=> 1
playlist.tracks             #=> (Track array)

# Search by category
party = RSpotify::Category.find('party')
party.playlists #=> (Playlist array)
categories = RSpotify::Category.list # See all available categories

# Access featured content from Spotify's Browse tab
featured_playlists = RSpotify::Playlist.browse_featured(country: 'US')
new_releases = RSpotify::Album.new_releases(country: 'ES')

# Access tracks' audio features
sorry = RSpotify::Track.search("Sorry").first
sorry.audio_features.danceability #=> 0.605
sorry.audio_features.energy #=> 0.768
sorry.audio_features.tempo #=> 100.209

# Get recommendations
recommendations = RSpotify::Recommendations.generate(seed_genres: ['blues', 'country'])
recommendations = RSpotify::Recommendations.generate(seed_tracks: my_fav_tracks.map(&:id))
recommendations = RSpotify::Recommendations.generate(seed_artists: my_fav_artists.map(&:id))
recommendations.tracks #=> (Track array)
```

## Rails + OAuth

You might want your application to access a user's Spotify account.

For instance, suppose you want your app to create playlists for the user based on their taste, or to add a feature that syncs user's playlists with some external app.

If so, add the following to your application (Remember to [get your credentials](https://developer.spotify.com/my-applications))

```ruby
# config/application.rb

RSpotify::authenticate("<your_client_id>", "<your_client_secret>")
```

```ruby
# config/initializers/omniauth.rb

require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, "<your_client_id>", "<your_client_secret>", scope: 'user-read-email playlist-modify-public user-library-read user-library-modify'
end
```

You should replace the scope values for the ones your own app will require from the user. You can see the list of available scopes in [here](https://developer.spotify.com/web-api/using-scopes).

Next, make a link so the user can log in with his Spotify account:

```ruby
<%= link_to 'Sign in with Spotify', '/auth/spotify' %>
```

And create a route to receive the callback:

```ruby
# config/routes.rb

get '/auth/spotify/callback', to: 'users#spotify'
```

Remember you need to tell Spotify this address is white-listed. You can do this by adding it to the Redirect URIs list in your [application page](https://developer.spotify.com/my-applications). An example of Redirect URI would be http://localhost:3000/auth/spotify/callback.

Finally, create a new RSpotify User with the response received:

```ruby
class UsersController < ApplicationController
  def spotify
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    # Now you can access user's private data, create playlists and much more

    # Access private data
    spotify_user.country #=> "US"
    spotify_user.email   #=> "example@email.com"

    # Create playlist in user's Spotify account
    playlist = spotify_user.create_playlist!('my-awesome-playlist')

    # Add tracks to a playlist in user's Spotify account
    tracks = RSpotify::Track.search('Know')
    playlist.add_tracks!(tracks)
    playlist.tracks.first.name #=> "Somebody That I Used To Know"

    # Access and modify user's music library
    spotify_user.save_tracks!(tracks)
    spotify_user.saved_tracks.size #=> 20
    spotify_user.remove_tracks!(tracks)

    albums = RSpotify::Album.search('launeddas')
    spotify_user.save_albums!(albums)
    spotify_user.saved_albums.size #=> 10
    spotify_user.remove_albums!(albums)

    # Use Spotify Follow features
    spotify_user.follow(playlist)
    spotify_user.follows?(artists)
    spotify_user.unfollow(users)

    # Get user's top played artists and tracks
    spotify_user.top_artists #=> (Artist array)
    spotify_user.top_tracks(time_range: 'short_term') #=> (Track array)

    # Check doc for more
  end
end
```

## Refreshing the access token

The user's access token is automatically refreshed by RSpotify when needed. This is especially useful if you persist
the user data on a database. This way, the user only need log in to Spotify once during the use of the application.

Additionally, you can store a proc that is invoked when a new access token is generated. This give you the
opportunity to persist the new access token for future use. The proc will be invoked with two arguments: the
new access token and the lifetime of the token in seconds. For example, if lifetime value returned from
Spotify is 3600, you know that the token will be good for one hour.

In the sample code below, the credentials have been retrieved from some persistent store such as
AWS SecretsManager.

```ruby

callback_proc = Proc.new { |new_access_token, token_lifetime |
   now = Time.now.utc.to_i  # seconds since 1/1/1970, midnight UTC
   deadline = now+token_lifetime
   #puts("new access token will expire at #{Time.at(deadline).utc.to_s}")
   self.save_new_access_token(new_access_token)
 }

spotify_user = RSpotify::User.new(
  {
    'credentials' => {
       "token" => self.credentials["access_token"],
       "refresh_token" => self.credentials["refresh_token"],
       "access_refresh_callback" => callback_proc
    } ,
    'id' => self.credentials["user_id"]
  })


```

RSpotify provides a way to facilitate persistence:

```ruby
hash = spotify_user.to_hash
# hash containing all user attributes, including access tokens

# Use the hash to persist the data the way you prefer...

# Then recover the Spotify user whenever you like
spotify_user = RSpotify::User.new(hash)
spotify_user.create_playlist!('my_awesome_playlist') # automatically refreshes token
```


## Getting raw response

To get the raw response from Spotify API requests, just toggle the `raw_response` variable:

```ruby
RSpotify.raw_response = true
RSpotify::Artist.search('Cher') #=> (String with raw json response)
```

## Notes

If you'd like to use OAuth outside rails, have a look [here](https://developer.spotify.com/web-api/authorization-guide/#authorization_code_flow) for the requests that need to be made. You should be able to pass the response to RSpotify::User.new just as well, and from there easily create playlists and more for your user.

## Contributing

1. Fork it ( https://github.com/guilhermesad/rspotify/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Test your changes (`bundle exec rspec`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
