class Track < ActiveRecord::Base
  belongs_to :playlist
  belongs_to :user

  def self.save_tracks(playlist, tracklist)

  end
end
