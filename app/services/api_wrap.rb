class ApiWrap
  MAX_RESULTS = 100 # reduce to increase genre variety
  PLAYLIST_TARGET_SIZE = 90 # leave under a multiple of MAX to reduce API calls

  def self.setup_artist_info(seed_artist)
    return { errors: "Seed artist can't be blank" } if seed_artist.blank?
    artist_response = get_artist_info(seed_artist)
    return artist_response if artist_response[:errors]
    artist_data   = artist_response[:response].first
    artist_name   = artist_data.name
    familiarity   = artist_data.familiarity

    genres_response = get_genres_array(artist_data)
    return genres_response if genres_response[:errors]
    genres_array = genres_response[:response]

    song_response = get_example_song_data(artist_name) # artist_name is for EN
    return song_response if song_response[:errors]
    song_data     = song_response[:response].first.audio_summary
    tempo         = song_data.tempo
    danceability  = song_data.danceability

    params = { familiarity: familiarity,
               tempo: tempo,
               danceability: danceability
             }
    { artist_name: artist_name, genres: genres_array, params: params }
  end

  def self.get_artist_info(seed_artist)
    response = Echowrap.artist_search(results: 1,
                           limit: true,
                           name: seed_artist,
                           bucket: ["id:spotify",
                                    :familiarity,
                                    :songs,
                                    :genre
                                    ]
                           )
    response.empty? ? self.info_error : { response: response }
  end

  def self.get_genres_array(artist_response)
    response = artist_response.to_hash[:genres].map(&:values).flatten
    response.empty? ? self.info_error : { response: response }
  end

  def self.get_example_song_data(seed_artist)
    response = Echowrap.song_search(artist: seed_artist,
                         results: 1,
                         sort: 'song_hotttnesss-desc',
                         limit: true,
                         bucket: ["id:spotify", :audio_summary, :tracks]
                        )
    response.empty? ? self.info_error : { response: response }
  end

  def self.make_new_playlist(playlist, current_user)
    token = current_user.session_token
    params = { json: true,
               body: { name: playlist.name,
                      "public" => false }.to_json,
               headers: {"Authorization" => "Bearer #{token}",
               "Content-Type" => "application/json"}
             }
    response = HTTParty.post("#{current_user.spotify_link}/playlists", params)
    if response["error"].present?
      { errors: response["error"]["message"] }
    else
      { playlist_data: response }
    end
  end

  def self.stitch_in_audio_summaries(all_playlists)
    unique_songs = uniquify_songs(all_playlists)
    key = ENV['ECHONEST_API_KEY']
    base_url = song_profile_url
    unique_songs.each_slice(20).with_object(complete_songs = []) do |song_batch|
      url = "#{base_url}api_key=#{key}&format=json&"
      url.concat("bucket=audio_summary&bucket=id:spotify&limit=true&")
      track_ids_string = songs_to_track_id_string(song_batch)
      url.concat(track_ids_string)
      result = HTTParty.get(url)["response"]["songs"]
      if result
        complete_songs.concat(add_audio_summary_data(song_batch, result))
      end
    end
  end

  def self.songs_to_track_id_string(unique_songs)
    unique_songs.map do |song|
      "track_id=" + song.tracks.first.foreign_id
    end.join("&")
  end

  def self.songs_by_genre(playlist, genre_name)
    Echowrap.playlist_static(genre: genre_name,
                             results: MAX_RESULTS,
                             limit: true,
                             min_tempo: playlist.min_tempo,
                             min_danceability: playlist.min_danceability,
                             artist_min_familiarity: playlist.min_familiarity,
                             song_type: "christmas:false",
                             type: 'genre-radio',
                             bucket: ["id:spotify",
                                     :song_type,
                                     :tracks
                                     ]
                            )
  end

  def self.get_playlist_tracks(playlist, current_user)
    token        = current_user.session_token
    spotify_id   = playlist.spotify_id
    spotify_link = playlist.user.spotify_link
    params = {
               headers: {"Authorization" => "Bearer #{token}"}
             }
    url = "#{spotify_link}/playlists/#{spotify_id}/tracks"
    HTTParty.get(url, params)
  end

  def self.post_tracks_to_spotify(playlist, tracklist, location)
    uri_array    = build_uri_array(tracklist)
    playlist.add_to_cached_uris(uri_array, location)
    token        = playlist.user.session_token
    spotify_id   = playlist.spotify_id
    spotify_link = playlist.user.spotify_link
    params = { body: { "uris" => uri_array }.to_json,
               headers: {"Authorization" => "Bearer #{token}",
               "Content-Type" => "application/json"}
             }
    url = "#{spotify_link}/playlists/#{spotify_id}/tracks"
    if location == "prepend"
      url.concat("?position=0")
    end
    HTTParty.post(url, params)
  end

  def self.build_uri_array(tracklist)
    tracklist.map(&:spotify_id)
  end

  def self.get_new_tracklist(playlist)
    playlist.genres.each_with_object(all_playlists = []) do |genre|
      next if all_playlists.length > PLAYLIST_TARGET_SIZE
      all_playlists += songs_by_genre(playlist, genre.name)
    end
    stitch_in_audio_summaries(all_playlists)
  end

  def self.unfollow_playlist(playlist, user)
    token       = user.session_token
    owner_id    = user.spotify_id
    playlist_id = playlist.spotify_id
    url = playlist_follow_url(owner_id, playlist_id)
    params = {
               headers: { "Authorization" => "Bearer #{token}" }
             }
    HTTParty.delete(url, params)
  end

  def self.follow_playlist(playlist, user)
    token       = user.session_token
    owner_id    = playlist.user.spotify_id
    playlist_id = playlist.spotify_id
    url = playlist_follow_url(owner_id, playlist_id)
    params = { body: { "public" => false },
               headers: { "Authorization" => "Bearer #{token}",
                          "Content-Type" => "application/json"}
             }
    response = HTTParty.put(url, params)
  end


private

  def self.info_error
    { errors: "Sorry couldn't find information for this artist" }
  end

  def self.uniquify_songs(all_songs)
    all_songs.uniq {|song| song.tracks.first.id }
  end

  def self.playlist_follow_url(owner_id, playlist_id)
    "https://api.spotify.com/v1/users/#{owner_id}/playlists/#{playlist_id}/followers"
  end

  def self.add_audio_summary_data(song_batch, audio_summaries)
    audio_summaries.each_with_object([]) do |summary, array|
      matched_song = song_batch.find { |song| song.id == summary["id"] }
      matched_song.update({ audio_summary: summary["audio_summary"] })
      array << matched_song
    end
  end

  def self.song_profile_url
    "http://developer.echonest.com/api/v4/song/profile?"
  end
end

