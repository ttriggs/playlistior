class Playlist < ActiveRecord::Base
  SONGS_LIMIT = 30
  has_many :genres, through: :styles
  has_many :styles, dependent: :destroy
  has_many :tracks, dependent: :destroy

  belongs_to :user

  def get_music_styles
    response = Echowrap.artist_search(results: 1,
                                      limit: true,
                                      name: seed_artist,
                                      bucket: ["id:spotify", :genre])
    genres_array = response.first.to_hash[:genres].map(&:values).flatten
    genres_array.each do |genre_name|
      genre = Genre.find_by(name: genre_name)
      styles.find_or_create_by(playlist: self, genre: genre ) if genre
    end
binding.pry if genres.empty? # genres?
  end

  def build_spotify_playlist
    if fresh_playlist?
      self.name        = "Playlistior: #{seed_artist}"
      new_playlist     = fetch_playlist
      self.spotify_id  = new_playlist["id"]
      self.link        = new_playlist["href"]
      self.user        = user
      self.seed_artist = seed_artist
      self.save! # to have playlist id ready for genre/style linking
      get_music_styles
      add_tracks
    end
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
    ordered_tracklist = Camelot.new(get_full_tracklist).order_tracks
    # Track.save_tracks(self, ordered_tracklist)
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
    build_taste_profile
    genres.each_with_object(all_playlists = []) do |genre, all|
      all_playlists += songs_by_genre(genre.name)
    end
    all_songs = uniquify_songs(all_playlists)
binding.pry
    formatted_songs_data = format_playlist_data(all_songs)
    update_taste_profile_with_tracks(formatted_songs_data)
    # get_all_track_data
binding.pry
  end

  def update_taste_profile_with_tracks(formatted_songs_data)
binding.pry if formatted_songs_data.nil?  #ready????
    response = Echowrap.taste_profile_update(id: taste_id,
                                  data: formatted_songs_data.to_json )
    self.update_attributes(taste_ticket: response.ticket)
binding.pry # check response
  end

  def format_playlist_data(all_songs)
    all_songs.each_with_object(data=[]) do |song, data|
      data << song_to_data_hash(song)
    end
  end

  def song_to_data_hash(song)
    { item: {
              # song_id: song.tracks.first.id,
              # song_name: song.title,
              track_id: song.tracks.first.foreign_id,
              item_keyvalues: { spotify_track_id: song.tracks.first.foreign_id }
              # favorite: false
              # banned: false
              # play_count: 0
              # skip_count: 0
            }
    }
  end

  def build_taste_profile
    result = Echowrap.taste_profile_create(name: name, type: 'song')
    id = result.id || result.to_hash[:status][:id]
    self.update_attributes(taste_id: id)
binding.pry  if id.nil? # add taste_id to playlist
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
    all_songs.uniq! {|song| song.tracks.first.id }
    # result.uniq!(&:song_hotttnesss) # remove duplicates
    # result.keep_if { |song| song.tracks.present? } # make sure track is present
  end
end
