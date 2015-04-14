class User < ActiveRecord::Base
  has_many :playlists, dependent: :destroy

  validates :spotify_id, uniqueness: { case_sensitive: false}

  def admin?
    role == "admin"
  end
end
