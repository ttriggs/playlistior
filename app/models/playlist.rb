class Playlist < ActiveRecord::Base
  SONGS_LIMIT = 50
  before_destroy :destroy_assignments, :destroy_follows
  has_many :genres, through: :styles
  has_many :styles, dependent: :destroy
  has_many :tracks, through: :assignments
  has_many :assignments
  has_many :follows

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
    playlist.setup_uri_array_if_needed(current_user)
    if playlist.fresh_playlist?
      playlist.name = "Playlistior: #{artist_name}"
      playlist.user = current_user
      response  = ApiWrap.make_new_playlist(playlist, current_user)
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
        playlist.add_tracks("prepend")
      else
        response
      end
    else
      playlist.record_music_styles(genres)
      playlist.add_tracks("append") # prepend playlist with 30 new songs
    end
  end

  def record_music_styles(genres_array)
    genres_array.each do |genre_name|
      genre = Genre.find_or_create_by(name: genre_name)
      styles.find_or_create_by(playlist: self, genre: genre ) if genre
    end
  end

  def setup_uri_array_if_needed(current_user)
    if has_snapshot? && has_no_tracks?
      response = ApiWrap.get_playlist_tracks(self, current_user)
      self.uri_array = uris_from_tracklist_response(response)
      self.save!
    end
  end

  def add_tracks(location)
    if location == "prepend" # on fresh "create"
      new_tracklist = ApiWrap.get_new_tracklist(self)
      save_tracks(new_tracklist)
    end
    if tracks.any?
      ordered_tracklist = Camelot.new(uri_array, tracks).order_tracks
      response = ApiWrap.post_tracks_to_spotify(self, ordered_tracklist, location)
      handle_add_tracks_response(response)
    else
      {
        errors: "Sorry no tracks found for this artist",
        playlist: self
      }
    end
  end

  def save_uri_array(uris, location)
    playlist_uris = get_uri_array
    if location == "append"
      self.uri_array = (playlist_uris += uris).to_s
    else
      self.uri_array = (uris += playlist_uris).to_s
    end
    self.save!
  end

  def get_uri_array
    uri_array.gsub(/\"/,"").tr("[]","").split(", ")
  end

  def save_tracks(tracks)
    tracks.each do |track|
      track = Track.find_or_build_track(track)
      self.tracks += [track]
    end
  end

  def handle_add_tracks_response(response)
    if response["snapshot_id"]
      self.snapshot_id = response["snapshot_id"]
      { playlist: self }
    else
      {
        errors: "Sorry could not create playlist for this artist",
        playlist: self
       }
    end
  end

  def owner?(current_user)
    current_user == user
  end

  def fresh_playlist?
    snapshot_id.nil? || has_no_tracks?
  end

  def min_tempo
    (tempo - 15).abs
  end

  def min_familiarity
    (familiarity - 0.1).abs
  end

  def min_danceability
    (danceability - 0.12).abs
  end

  def spotify_embed
    "https://embed.spotify.com/?uri=spotify:user:#{user.spotify_id}:playlist:#{spotify_id}"
  end

  def increment_followers_cache
    self.follows_cache += 1
    self.save!
  end

  def decrement_followers_cache
    self.follows_cache -= 1
    self.save!
  end

  private

  def uris_from_tracklist_response(response)
    response["items"].map do |track|
      track["track"]["uri"]
    end.to_s
  end

  def has_snapshot?
    !snapshot_id.nil?
  end

  def has_tracks?
    tracks.length > 0
  end

  def has_no_tracks?
    !has_tracks?
  end

  def destroy_assignments
    Assignment.where(playlist_id: id).destroy_all
  end

  def destroy_follows
    Follow.where(playlist_id: id).destroy_all
  end
end


