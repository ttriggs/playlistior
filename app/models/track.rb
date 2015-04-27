class Track < ActiveRecord::Base
  has_many :playlists, through: :assignments
  has_many :assignments

  def self.find_or_build_track(song)
    echonest_id = song.id
    track = Track.find_or_initialize_by(echonest_id: echonest_id)
    if track.persisted?
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
end
