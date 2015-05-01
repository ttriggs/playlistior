class Track < ActiveRecord::Base
  has_many :playlists, through: :assignments
  has_many :assignments

  validates :artist_name, presence: true
  validates :echonest_id, uniqueness: true
  validates :spotify_id, presence: true
  validates :title, presence: true
  validates :key, numericality: { only_integer: true }
  validates :mode, inclusion: { in: 0..1 }
  validates :tempo, numericality: true
  validates :energy, numericality: true
  validates :liveness, numericality: true
  validates :danceability, numericality: true
  validates :time_signature, numericality: true

  def self.find_or_build_track(song)
    echonest_id = song.id
    track = Track.find_or_initialize_by(echonest_id: echonest_id)
    if track.fresh?
      track.title       = song.title
      track.spotify_id  = song.tracks.first.foreign_id
      track.artist_name = song.artist_name
      summary  = song.audio_summary.to_hash
      track.key = summary["key"]
      track.mode  = summary["mode"]
      track.tempo  = summary["tempo"]
      track.energy  = summary["energy"]
      track.liveness  = summary["liveness"]
      track.danceability = summary["danceability"]
      track.time_signature = summary["time_signature"]
      track.save!
    end
    track
  end

  def self.create_by_track_data(track_data)
    echonest_id = track_data["echonest_id"]
    track = Track.find_or_initialize_by(echonest_id: echonest_id)
    track.id = track_data["id"]
    track.key = track_data["key"]
    track.mode = track_data["mode"]
    track.title = track_data["title"]
    track.tempo = track_data["tempo"]
    track.energy = track_data["energy"]
    track.liveness = track_data["liveness"]
    track.spotify_id = track_data["spotify_id"]
    track.artist_name = track_data["artist_name"]
    track.danceability = track_data["danceability"]
    track.time_signature = track_data["time_signature"]
    track.save!
    track
  end

  def fresh?
    artist_name.nil?
  end
end
