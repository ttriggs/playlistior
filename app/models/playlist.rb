class Playlist < ActiveRecord::Base
  SONGS_LIMIT = 30
  has_many :genres, through: :styles
  has_many :styles, dependent: :destroy
  has_many :tracks, through: :assignments
  has_many :assignments, dependent: :destroy

  belongs_to :user

  def get_music_styles
    response = Echowrap.artist_search(results: 1,
                                      limit: true,
                                      name: seed_artist,
                                      bucket: ["id:spotify", :genre])
    genres_array = response.first.to_hash[:genres].map(&:values).flatten
    genres_array.take(2).each do |genre_name|
      genre = Genre.find_by(name: genre_name)
      styles.find_or_create_by(playlist: self, genre: genre ) if genre
    end
binding.pry if genres.empty? # genres wuhh??
  end

  def build_spotify_playlist
    if fresh_playlist?
      self.name        = "Playlistior: #{seed_artist}"
      new_playlist     = fetch_playlist
      self.spotify_id  = new_playlist["id"]
      self.user        = user
      self.link        = new_playlist["href"]
      self.seed_artist = seed_artist
      self.save! # to have playlist id ready for genre/style linking
      get_music_styles
      add_tracks
    end
  end

  def spotify_embed
    "https://embed.spotify.com/?uri=spotify:user:#{user.spotify_id}:playlist:#{spotify_id}"
  end

  def create_empty_playlist
    params = { json: true,
               body: { name: name,
                      "public" => false }.to_json,
               headers: {"Authorization" => "Bearer #{create_token}",
               "Content-Type" => "application/json"}
             }
    HTTParty.post("#{user.spotify_link}/playlists", params)
  end

  def fresh_playlist?
    tracks.none?
  end

  def fetch_playlist
    handle_response { create_empty_playlist }
  end

  def handle_response(&block)
    response = block.call
    if response["error"].present?
binding.pry # errorzzzz???
      failure(response["error"]["message"])
    else
      response
    end
  end

  def failure(message="")
    flash[:alert] = "Unable to create playlist. #{message}"
    redirect_to root_path
  end

  def add_tracks
    # full_tracklist = get_full_tracklist
    ordered_tracklist = Camelot.new(get_full_tracklist).order_tracks
    # Track.save_tracks(get_full_tracklist, genres.first.group_id)
    uri_array = build_uri_array(ordered_tracklist)
    params = { body: { "uris"=> uri_array }.to_json,
               headers: {"Authorization" => "Bearer #{create_token}",
               "Content-Type" => "application/json"}
             }
    url = "#{user.spotify_link}/playlists/#{spotify_id}/tracks"
    HTTParty.post(url, params)
  end

  def build_uri_array(tracklist)
    tracklist.map do |song|
      song.tracks.first.foreign_id
    end
  end

  def get_full_tracklist
    genres.each_with_object(all_playlists = []) do |genre, all|
      all_playlists += songs_by_genre(genre.name)
    end
    unique_songs = uniquify_songs(all_playlists)
binding.pry if unique_songs.nil? #NILL???
    get_audio_summaries(unique_songs)
  end

  def get_audio_summaries(unique_songs)
    key = ENV['ECHONEST_API_KEY']

    base_url = "http://developer.echonest.com/api/v4/song/profile?"
    unique_songs.each_slice(20).with_object(complete_songs = []) do |song_batch|
      url = "#{base_url}api_key=#{key}&format=json&"
      url.concat("bucket=audio_summary&bucket=id:spotify&limit=true&")
      track_ids_string = songs_to_track_id_string(song_batch)
      url.concat(track_ids_string)
      response = HTTParty.get(url)["response"]["songs"]
      if response
        complete_songs.concat(add_audio_summary_data(song_batch, response))
      end
    end
  end

  def add_audio_summary_data(song_batch, audio_summaries)
    audio_summaries.each_with_object([]) do |summary, array|
      matched_song = song_batch.find { |song| song.id == summary["id"] }
      matched_song.update({ audio_summary: summary["audio_summary"] })
      array << matched_song
    end
  end


  def songs_to_track_id_string(unique_songs)
    unique_songs.map do |song|
      "track_id=" + song.tracks.first.foreign_id
    end.join("&")
  end

  def songs_by_genre(genre_name)
    result = Echowrap.playlist_basic(genre: genre_name,
                                     results: 100,
                                     limit: true,
                                     type: 'genre-radio',
                                     bucket: ["id:spotify",
                                              :song_type,
                                              :tracks
                                              ]
                                    )
  end

  def uniquify_songs(all_songs)
    all_songs.uniq {|song| song.tracks.first.id }
    # result.uniq!(&:song_hotttnesss) # remove duplicates
    # result.keep_if { |song| song.tracks.present? } # make sure track is present
  end
end

  # def batch_in_hash(batch_songs_data)
  #   batch_songs_data.each_with_object(data = {}) do |song|
  #     hashed = { song["id"] => song["audio_summary"] }
  #     data.merge!(hashed)
  #   end
  # end

#   def update_taste_profile_with_tracks(formatted_songs_data)
# binding.pry if formatted_songs_data.nil?  #ready????
#     response = Echowrap.taste_profile_update(id: taste_id,
#                                   data: formatted_songs_data.to_json )
#     self.update_attributes(taste_ticket: response.ticket)
# binding.pry # check response
#   end


  # def song_to_data_hash(song)
  #   { item: {
  #             # song_id: song.tracks.first.id,
  #             # song_name: song.title,
  #             track_id: song.tracks.first.foreign_id,
  #             item_keyvalues: { spotify_track_id: song.tracks.first.foreign_id }
  #             # favorite: false
  #             # banned: false
  #             # play_count: 0
  #             # skip_count: 0
  #           }
  #   }
  # end

  # def format_playlist_data(all_songs)
  #   all_songs.each_with_object(data=[]) do |song, data|
  #     data << song_to_data_hash(song)
  #   end
  # end


#   def build_taste_profile
#     result = Echowrap.taste_profile_create(name: name, type: 'song')
#     id = result.id || result.to_hash[:status][:id]
#     self.update_attributes(taste_id: id)
# binding.pry  if id.nil? # add taste_id to playlist
#   end
