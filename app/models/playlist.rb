class Playlist < ActiveRecord::Base
  SONGS_LIMIT = 30
  has_many :genres, through: :styles
  has_many :styles, dependent: :destroy
  has_many :tracks, through: :assignments
  has_many :assignments, dependent: :destroy

  belongs_to :user

  validates :seed_artist, presence: true

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
      self.name = "Playlistior: #{seed_artist}"
      self.user = user
      response  = make_new_playlist # how: get error to view from here??
      if response["id"] # if didn't fail...
        self.spotify_id  = response["id"]
        self.link        = response["href"]
        self.seed_artist = seed_artist
        self.save! # to have playlist id ready for genre/style linking
        get_music_styles
        add_tracks
      else
        response
      end
    end
  end

  def make_new_playlist
    handle_response { create_empty_playlist }
  end

  def create_empty_playlist
    token = user.session_token
    params = { json: true,
               body: { name: name,
                      "public" => false }.to_json,
               headers: {"Authorization" => "Bearer #{token}",
               "Content-Type" => "application/json"}
             }
    HTTParty.post("#{user.spotify_link}/playlists", params)
  end

  def fresh_playlist?
    snapshot_id.nil?
  end

  def add_tracks
    ordered_tracklist = Camelot.new(get_full_tracklist).order_tracks
    # Track.save_tracks(get_full_tracklist, genres.first.group_id)
    uri_array = build_uri_array(ordered_tracklist)
    post_tracks_to_spotify(uri_array)
  end

  def post_tracks_to_spotify(uri_array)
    params = { body: { "uris"=> uri_array }.to_json,
               headers: {"Authorization" => "Bearer #{user.session_token}",
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
binding.pry if unique_songs.nil? # NILL???
    stitch_in_audio_summaries(unique_songs)
  end

  def stitch_in_audio_summaries(unique_songs)
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

  def spotify_embed
    "https://embed.spotify.com/?uri=spotify:user:#{user.spotify_id}:playlist:#{spotify_id}"
  end

  private

  def uniquify_songs(all_songs)
    all_songs.uniq {|song| song.tracks.first.id }
  end

  def handle_response(&block)
    response = block.call
    if response["error"].present?
binding.pry # errorzzzz???
      [ response["error"]["message"] ]
    else
      response
    end
  end

  def self.get_genres_in_use
    Playlist.all
  end

end
