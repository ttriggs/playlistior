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
  end

  def build_spotify_playlist
    if fresh_playlist?
      new_playlist = fetch_playlist
      self.name        = new_playlist["name"]
      self.spotify_id  = new_playlist["id"]
      self.link        = new_playlist["href"]
      self.user        = user
      self.seed_artist = seed_artist
      self.save! # to have playlist id ready for genre/style linking
      get_music_styles
      add_tracks
    end
  end

  def fresh_playlist?
    tracks.none?
  end

  def fetch_playlist
    response = create_empty_playlist
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

  def create_empty_playlist
    params = { json: true,
               body: { name: "Playlistior: #{seed_artist}",
                      "public" => false }.to_json,
               headers: {"Authorization" => "Bearer #{create_token}",
               "Content-Type" => "application/json"}
             }
    HTTParty.post("#{user.spotify_link}/playlists", params)
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


  def add_tracks_to_playlist
binding.pry
  end

  def get_full_tracklist
    genres.each_with_object([]) do |genre, array|
      array << songs_by_genre(genre.name)
    end
  end

  def songs_by_genre(genre_name)
    result = Echowrap.playlist_basic(genre: genre_name,
                                     results: 13,
                                     limit: true,
                                     type: 'genre-radio',
                                     bucket: ["id:spotify", :tracks])
    # result = Echowrap.song_search(style: genre_name,
    #                               results: 100,
    #                               bucket: ["id:spotify-WW",
    #                                       :song_hotttnesss,
    #                                       :audio_summary, :tracks])
    filter_song_search_results(result)
  end

  def filter_song_search_results(result)
binding.pry # double check filter methods
    result.uniq!(&:song_hotttnesss) # remove duplicates
    result.keep_if { |song| song.tracks.present? } # make sure track is present
binding.pry
  end
end
