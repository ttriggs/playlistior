[![Build Status](https://travis-ci.org/ttriggs/playlistior.svg?branch=master)](https://travis-ci.org/ttriggs/playlistior) [![Code Climate](https://codeclimate.com/github/ttriggs/playlistior.png)](https://codeclimate.com/github/ttriggs/playlistior) [![Coverage Status](https://coveralls.io/repos/ttriggs/playlistior/badge.png)](https://coveralls.io/r/ttriggs/playlistior)

# Playlistior
### The Superior Harmonic Playlist Generator
[Try it out here](http://playlistior.herokuapp.com "Try Playlistior!")

## Playlistior Demo:
[Playlistior App Demo](http://i.imgur.com/aifS5jR.gifv)

## About:
Playlistior: The superior playlist generator.

When given a starting seed artist, Playlistior uses audio information from the Echonest API for each song (key, mode, tempo, daceability, and how familiar the artist is to the public) to construct a playlist that flows harmonically from one song to the next. Check the "Adventurous" box to loosen these constraints to help you find lesser known artists. Under the hood, the generator uses an algorithm inspired by "harmonic mixing," a technique used by DJs to avoid disharmonious song changes.

## Under the hood:
### Playlist Creation steps:
Note: API interactions happen within the services/api_wrap.rb file.

- The user supplied seed artist is verified with Echonest and artist-specific information is returned including, artist familiarity to the public, and genres associated with the artist.
- Another API request gets tempo and danceability data on a sample song by the artist
- Familiarity, tempo, & danceability are optionally used to apply limits on the Echonest's playlist generator method. If the user checks the "Feeling Adventurous?" checkbox, the minimum requirements will be removed. If the box is left unchecked (default) these minimum requirements will constrain Echonest's playlist results to songs with a similar profile to the seed artist and sample song.
- To build a new playlist, I'm using the Echonest playlist_static method which  allows you to supply a genre name as well as minimums for tempo, danceability, and familiarity.
- Within api_wrap.rb, two constants dictate how the playlists are compiled. Their current settings are: ``` MAX_RESULTS = 100 ``` and ``` PLAYLIST_TARGET_SIZE = 90 ```
- Generally speaking, Playlistior will loop through the array of genres associated with an artist and call Echonest's playlist_static method to request a playlist of ```MAX_RESULTS``` songs within the genre [and within any other constraints (danceability, tempo, familiarity)]. If the total number of songs returned is less than ```PLAYLIST_TARGET_SIZE```, Playlistior will issue more playlist_static requests using the next genre in the array till it's out of genres to search or the total number of songs returned is greater than ```PLAYLIST_TARGET_SIZE```. After each request, the new results are concatenated with any previous results. To avoid duplicate songs, they are uniquified by thier echonest track id. This is the unordered tracklist for the harmonic mixing algorithm (performed within services/camelot.rb)
- ```MAX_RESULTS``` is used in the Echonest playlist_static call to specify the number of songs expected in return.
- ```PLAYLIST_TARGET_SIZE``` is used to internally limit how many songs are needed before a playlist can be created. If this number is increased above ```MAX_RESULTS```, multiple calls to Echonest's playlist_static uri will be made with different genres associated with the seed artist. This will increase genre variability in you playlists, but at the expense of load times.
- Once all unique songs are collected, audio summary data is collected for each song and pushed into each song's data structure (including: key, mode, liveness, time_signature, danceability, tempo, and energy). Key and mode will be used by the harmonic mixing algorithm, other info is/will be used in visualizing the playlist data on the show page.
- All unique songs are saved to the tracks table and are associated with the playlist.
- [Side Note]: One rarely occuring known issue: In Echonest's database, some artists have few to no genres associated with them this may prevent the Echonest playlists_static method from returning all ```MAX_RESULTS``` songs. For example "Die Antwoord" only has one associated Echonest genre: "african rock" - a genre for which they are the only artist. This results in a playlist that is 27 songs of just Die Antwoord songs.

[Camelot Mixing Wheel Image](http://www.djingtips.com/sites/default/files/resize/styles/extra_large/public/images/camelot_wheel_0-294x294.jpg)

### Harmonic mixing steps, "Camelot" class
Harmonic Mixing or the "Camelot System" of mixing requires first finding one song's position on the Camelot wheel. From there, a suitable next song's parameters are located one move to the left or right or moving between the inner and outer rings of the wheel.
- Once an unorederd list of songs is compiled, the Camelot POR class does the ordering
- First, it picks a random starting track and adds it to the ordered list to be output.
- The first track's key and mode are translated into a zone on the Camelot wheel.
- Neighbor zones are found (one move left, one move right, or inner <-> outer ).
- The algorithm tries to find a suitable next track that matches one of the neighbor zone parameters.
- If it fails to find one, it will pick a random track and continue.
- A playlist is complete if it runs out of unused tracks or if the ordered list hits the ```Playlist::SONGS_LIMIT``` constant (currently set to 30).


## Notes on using the APIs:
API calls to Echonest can be slow so increasing the number of calls to generate a playlist can greatly reduce a playlist's load time. Two to three calls requesting a playlist of 100 songs each may take 30+ seconds. This is fine if you're running it locally, but cause issues on Heroku as a timeout error occures if the page load is >30s. For now, I've reduced the playlist requests by setting (within services/api_wrap.rb) ``` MAX_RESULTS = 100 ``` and ``` PLAYLIST_TARGET_SIZE = 90 ```
This will limit results to 100 songs in the first Echonest playlist API request and so long as 100 songs are actually returned, the generator will not request a second batch.

## Clone it!
```
git clone https://github.com/ttriggs/playlistior.git playlistior
rake db:create
rake db:migrate
rake db:seed
```

## To Do
### Frontend
- better navigation around app (add create button within topbar when on small screen)
  - Use jQuery for a search field to appear on click?
- Use Ajax for following a playlist without refresh
- Add a "?" icon next to "Feeling Adventurous?" checkbox to explain its function
  - Use jQuery to toggle an explaination?
- Album art cover carousel on playlist show page?
- Create "About" page

### Backend
- Use Ajax to create new playlists, show a loading spinner, then serve playlist page (this should circumvent Heroku's page timeout issue). Avoiding this timeout issue will allow more flexibility in how playlists are put together. Currently, the Heroku build tries to get all the songs it needs to build a playlist in one Echonest playlist_static call using the first genre associated with the artist. Fixing this timeout issue will mean more genres associated with the artist will be represented in the playlist created.
- Add play order to assignments. Currently chart functionality uses the track order stored in the playlist to query the tracks table to assemble the ordered list.
- Camelot: allow for more varied styles of playlist creation
  - "wandering" mode: current default, next song is a random Camelot wheel neighbor
  - "up/down" mode: build a playlist that only increases/decreases in camelot zone #
  - "alternate" mode: switch from minor to major more frequently (currently the algorithm is somewhat unlikely to switch keys because neighboring zones are more likely to be in the same mode)

### Misc or Back & Front
- Highcharts:
  - allow users to toggle between different visualizations of the playlist. Currently, the default is to display song "energy" as the bubble size. Other parameters worth adding: tempo, danceability, & liveness).

