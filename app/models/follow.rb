class Follow < ActiveRecord::Base
  belongs_to :playlists
  belongs_to :users

  validates :user_id, presence: true
  validates :playlist_id, presence: true

end
