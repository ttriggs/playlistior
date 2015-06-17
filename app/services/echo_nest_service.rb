class EchoNestService
  MAX_RESULTS = 100 # reduce to increase genre variety
  PLAYLIST_TARGET_SIZE = 90 # leave under a multiple of MAX to reduce API calls

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
    EchoNestResponse.new(response.first).return("artist")
  end

  def self.get_demo_song_data(artist)
    response = Echowrap.song_search(artist: artist,
                                    results: 1,
                                    sort: 'song_hotttnesss-desc',
                                    limit: true,
                                    bucket: ["id:spotify",
                                             :audio_summary,
                                             :tracks]
                                   )
    EchoNestResponse.new(response.first).return("song data")
  end

  def self.songs_to_track_id_string(unique_songs)
    unique_songs.map do |song|
      "track_id=" + song.tracks.first.to_hash[:foreign_id]
    end.join("&")
  end

  def self.get_new_tracklist(playlist, limit = MAX_RESULTS, target = PLAYLIST_TARGET_SIZE)
    playlist.genres.each_with_object(all_playlists = []) do |genre|
      next if all_playlists.length > target
      all_playlists += songs_by_genre(playlist, genre.name, limit)
    end
    stitch_in_audio_summaries(all_playlists)
  end

  def self.songs_by_genre(playlist, genre_name, limit)
    Echowrap.playlist_static(genre: genre_name,
                             results: limit,
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

  def self.stitch_in_audio_summaries(all_playlists)
    unique_songs = uniquify_songs(all_playlists)
    key = ENV['ECHONEST_API_KEY']
    base_url = song_profile_url
    unique_songs.each_slice(20).with_object(complete_songs = []) do |song_batch|
      url = "#{base_url}api_key=#{key}&format=json&"
      url += "bucket=audio_summary&bucket=id:spotify&limit=true&"
      track_ids_string = songs_to_track_id_string(song_batch)

      url.concat(track_ids_string)
      result = HTTParty.get(url)["response"]["songs"]
      if result
        complete_songs.concat(add_audio_summary_data(song_batch, result))
      end
    end
  end

  def self.uniquify_songs(all_songs)
    all_songs.uniq {|song| song.tracks.first.to_hash[:id] }
  end

  def self.add_audio_summary_data(song_batch, audio_summaries)
    audio_summaries.each_with_object([]) do |summary, array|
      matched_song = song_batch.find { |song| song.id == summary["id"] }
      if !matched_song.nil?
        matched_song.update({ audio_summary: summary["audio_summary"] })
        array << matched_song
      end
    end
  end

  def self.song_profile_url
    "http://developer.echonest.com/api/v4/song/profile?"
  end

  class EchoNestResponse
    def initialize(response)
      @response = response
    end

    def failed?
      !@response.present?
    end

    def return(type)
      return artist_not_found_error if failed?
      if type == "artist"
        parsed_artist_data
      elsif type == "song data"
        parsed_song_data(@response.audio_summary)
      end
    end

    def parsed_artist_data
      artist_name = @response.name
      familiarity = @response.familiarity
      data = { artist_name: artist_name, familiarity: familiarity }
      data.merge!(genres_from_response)
    end

    def parsed_song_data(audio_summary)
      tempo = audio_summary.tempo
      danceability = audio_summary.danceability
      { tempo: tempo, danceability: danceability }
    end

    def genres_from_response
      genres = @response.attrs[:genres].map(&:values).flatten
      if genres.empty?
        artist_not_found_error
      else
        { genres: genres }
      end
    end

    def artist_not_found_error
      { errors: "Sorry, couldn't find data for this artist." }
    end
  end
end
