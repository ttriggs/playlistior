class Playlist < ActiveRecord::Base
  SONGS_LIMIT = 30
  has_many :genres, through: :styles
  has_many :styles, dependent: :destroy
  has_many :tracks, through: :assignments
  has_many :assignments, dependent: :destroy

  belongs_to :user

  validates :seed_artist, presence: true
  validates :user, presence: true

  def self.fetch_or_build_playlist(seed_artist, adventurous, current_user)
    response = ApiWrap.get_artist_info(seed_artist)
    return response if response[:errors]
    genres          = response[:genres]
    artist_name     = response[:artist_name]
    playlist_params = response[:params]
    playlist = Playlist.find_or_initialize_by(user: current_user,
                                              seed_artist: seed_artist)
    if playlist.fresh_playlist?
      playlist.name = "Playlistior: #{artist_name}"
      playlist.user = current_user
      response  = ApiWrap.make_new_playlist(current_user)
      if !response[:errors]
        playlist.link         = response["href"]
        playlist.spotify_id   = response["id"]
        playlist.seed_artist  = artist_name
        playlist.adventurous  = adventurous
        playlist.tempo        = playlist_params[:tempo]
        playlist.familiarity  = playlist_params[:familiarity]
        playlist.danceability = playlist_params[:danceability]
        playlist.save! # need playlist id ready for genre/style linking
        playlist.record_music_styles(genres)
        result = playlist.add_tracks("prepend")
        { playlist: playlist, snapshot_id: result["snapshot_id"] }
      else
        response
      end
    else
      result = playlist.add_tracks("append") # prepend playlist with 30 new songs
      { playlist: playlist, snapshot_id: result["snapshot_id"] }
    end
  end

  def record_music_styles(genres_array)
    genres_array.take(2).each do |genre_name|
      genre = Genre.find_by(name: genre_name)
      styles.find_or_create_by(playlist: self, genre: genre ) if genre
    end
  end

  def add_tracks(location="append")
    ordered_tracklist = Camelot.new(get_full_tracklist).order_tracks
    # Track.save_tracks(get_full_tracklist, genres.first.group_id)
    uri_array = build_uri_array(ordered_tracklist)
    ApiWrap.post_tracks_to_spotify(self, uri_array, location)
  end

  def get_full_tracklist
    genres.each_with_object(all_playlists = []) do |genre, all|
      all_playlists += ApiWrap.songs_by_genre(self, genre.name)
    end
    unique_songs = uniquify_songs(all_playlists)
binding.pry if unique_songs.nil? # NILL???
    ApiWrap.stitch_in_audio_summaries(unique_songs)
  end

  def build_uri_array(tracklist)
    tracklist.map do |song|
      song.tracks.first.foreign_id
    end
  end

  def owner?(current_user)
    current_user == user
  end

  def fresh_playlist?
    snapshot_id.nil?
  end

  def min_tempo
    ((tempo || 85) - 15).abs
  end

  def min_familiarity
    ((familiarity || 0.3 ) - 0.15).abs
  end

  def min_danceability
    ((danceability || 0.2 ) - 0.15).abs
  end


  def spotify_embed
    "https://embed.spotify.com/?uri=spotify:user:#{user.spotify_id}:playlist:#{spotify_id}"
  end

  private

  def uniquify_songs(all_songs)
    all_songs.uniq {|song| song.tracks.first.id }
  end
end


