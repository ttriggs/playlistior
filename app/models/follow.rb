class Follow < ActiveRecord::Base
  belongs_to :playlist
  belongs_to :user

  validates :user_id, presence: true
  validates :playlist_id, presence: true

end
