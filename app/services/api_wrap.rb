class ApiWrap

  def self.get_artist_info(seed_artist)
    return { errors: "Seed artist can't be blank" } if seed_artist.blank?
    response = Echowrap.artist_search(results: 1,
                                      limit: true,
                                      name: seed_artist,
                                      bucket: ["id:spotify",
                                               :familiarity,
                                               :songs,
                                               :genre
                                               ]
                                      )
    if response.empty?
      return { errors: "Sorry couldn't find information for artist: #{seed_artist}" }
    end
    genres_array = response.first.to_hash[:genres].map(&:values).flatten
    if genres_array.empty?
      return { errors: "Sorry couldn't find information for artist: #{seed_artist}" }
    end
    artist_name   = response.first.name
    familiarity   = response.first.familiarity
    song_response = get_example_song_data(seed_artist)
    tempo         = song_response.first.audio_summary.tempo
    danceability  = song_response.first.audio_summary.danceability
    params = { familiarity: familiarity,
               tempo: tempo,
               danceability: danceability
             }
    { artist_name: artist_name, genres: genres_array, params: params }
  end

  def self.get_example_song_data(seed_artist)
    Echowrap.song_search(artist: seed_artist,
                         results: 1,
                         sort: 'song_hotttnesss-desc',
                         limit: true,
                         bucket: ["id:spotify", :audio_summary, :tracks]
                        )
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
      response
    end
  end

  def self.stitch_in_audio_summaries(unique_songs)
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
                             results: 100,
                             limit: true,
                             min_tempo: playlist.min_tempo,
                             min_danceability: playlist.min_danceability,
                             artist_min_familiarity: playlist.min_familiarity,
                             type: 'genre-radio',
                             bucket: ["id:spotify",
                                     :song_type,
                                     :tracks
                                     ]
                           )
  end

  def self.post_tracks_to_spotify(playlist, uri_array, location)
    token        = playlist.user.session_token
    spotify_id   = playlist.spotify_id
    spotify_link = playlist.user.spotify_link
    params = { body: { "uris"=> uri_array }.to_json,
               headers: {"Authorization" => "Bearer #{token}",
               "Content-Type" => "application/json"}
             }
    url = "#{spotify_link}/playlists/#{spotify_id}/tracks"
    if location == "prepend"
      url.concat("?position=0")
    end
    HTTParty.post(url, params)
  end

  def self.unfollow_playlist(playlist)
    playlist_id = playlist.spotify_id
    owner_id = playlist.user.spotify_id
    token = playlist.user.session_token
    url = "https://api.spotify.com/v1/users/#{owner_id}/playlists/#{playlist_id}/followers"
    params = {
               headers: { "Authorization" => "Bearer #{token}" }
             }
    HTTParty.delete(url, params)
  end

private

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
