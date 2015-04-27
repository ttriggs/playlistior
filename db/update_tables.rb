
# 1) remove all cached graphs
# 2) get tracks currently in playlist and write to playlists

Playlist.all.shuffle.each do |playlist|
  Hlpr.clear_cached_charts_json(playlist)
  all_tracks_data = Hlpr.get_audio_summaries(playlist)
  all_tracks_data.each_with_index do |song_data, index|
    spotify_id = playlist.get_uri_array[index]
    track = Track.find_or_initialize_by(spotify_id: spotify_id)
    if !track.persisted?
      track.title       = song_data["title"]
      track.artist_name = song_data["artist_name"]
      track.echonest_id = song_data["id"]
      track.spotify_id  = spotify_id
      audio_summary      = song_data["audio_summary"]
      track.time_signature = audio_summary["time_signature"]
      track.danceability = audio_summary["danceability"]
      track.liveness = audio_summary["liveness"]
      track.energy = audio_summary["energy"]
      track.key  = audio_summary["key"]
      track.mode = audio_summary["mode"]
      track.tempo = audio_summary["tempo"]
      track.save!
      playlist.tracks += [track]
      puts ">> ++ SAVED new track!: #{track.title} by #{track.artist_name} ++"
    else
      puts ">> FOUND track!: #{track.title} by #{track.artist_name}"
    end
  end
  Hlpr.do_sleep(10)
end
