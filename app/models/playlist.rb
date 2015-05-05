class Playlist < ActiveRecord::Base

  SONGS_LIMIT = 30
  CHARTS_CACHES = [:energy_json_cache, :liveness_json_cache, :tempo_json_cache, :danceability_json_cache]

  before_destroy :destroy_assignments, :destroy_follows
  has_many :genres, through: :styles
  has_many :styles, dependent: :destroy
  has_many :tracks, through: :assignments
  has_many :assignments
  has_many :follows

  belongs_to :user

  validates :seed_artist, presence: true
  validates :snapshot_id, presence: true
  validates :user, presence: true
  validates :name, presence: true
  validates :link, presence: true

  def self.fetch_or_build_playlist(playlist_params, current_user)
    artist_name = playlist_params[:artist_name]
    playlist = Playlist.find_or_initialize_by(user: current_user,
                                              seed_artist: artist_name,
                                              name: "Playlistior: #{artist_name}")
    if playlist.not_on_spotify?
      playlist.build_playlist_for_spotify(playlist_params)
    end
    playlist
  end

  def build_playlist_for_spotify(playlist_params)
    user_spotify_id = self.user.spotify_id
    response = spotify_service.create_playlist(user_spotify_id, name)
    if !response[:errors]
      self.link         = response["href"]
      self.snapshot_id  = response["snapshot_id"]
      self.adventurous  = playlist_params[:adventurous]
      self.familiarity  = playlist_params[:familiarity]
      self.tempo        = playlist_params[:tempo]
      self.danceability = playlist_params[:danceability]
      save_genres(playlist_params[:genres]) if self.save
    end
  end

  def spotify_service
    SpotifyService.new(user.session_token)
  end

  def save_genres(genres)
    genres.each do |genre_name|
      genre = Genre.find_or_create_by(name: genre_name)
      styles.find_or_create_by(playlist: self, genre: genre) if genre
    end
  end

  def update_cached_uris(uris, location)
    playlist_uris = get_uri_array
    if location == "append"
      self.uri_array = (playlist_uris + uris).to_s
    else
      self.uri_array = (uris + playlist_uris).to_s
    end
    self.save!
  end

  def get_uri_array
    uri_array.gsub(/\"/,"").tr("[]","").split(", ")
  end

  def active_tracks_in_order
    order = 1
    get_uri_array.each_with_object(active_tracks = []) do |spotify_id|
      track = tracks.where(spotify_id: spotify_id)
      active_tracks += [{ track: track.first, order: order }] if track.any?
      order += 1
    end
    active_tracks
  end

  def clear_cached_charts_json
    CHARTS_CACHES.each do |cached_chart|
      self[cached_chart] = nil
    end
    self.save!
  end

  def update_uri_array(tracklist)
    update(uri_array: tracklist.map(&:spotify_id).to_s)
    clear_cached_charts_json
  end

  def owner?(current_user)
    current_user == user
  end

  def owner_or_admin?(current_user)
    owner?(current_user) || current_user.admin?
  end

  def not_on_spotify?
    snapshot_id.nil? || has_no_tracks?
  end

  def spotify_id
    link.split("/").last
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
    spotify_user_uri = "uri=spotify:user:#{user.spotify_id}"
    playlist_uri     = "playlist:#{spotify_id}"
    "https://embed.spotify.com/?#{spotify_user_uri}:#{playlist_uri}"
  end

  def increment_followers_cache
    self.follows_cache += 1
    self.save!
  end

  def decrement_followers_cache
    self.follows_cache -= 1
    self.save!
  end

  def has_no_tracks?
    !has_tracks?
  end

  def has_tracks?
    tracks.length > 0
  end

  def has_snapshot?
    !snapshot_id.nil?
  end

  private

  def needs_new_uri_array?
    has_tracks? && get_uri_array.empty?
  end

  # def uris_from_tracklist_response(response)
  #   response["items"].map do |track|
  #     track["track"]["uri"]
  #   end.to_s
  # end

  def destroy_assignments
    Assignment.where(playlist_id: id).destroy_all
  end

  def destroy_follows
    Follow.where(playlist_id: id).destroy_all
  end
end


