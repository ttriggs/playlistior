class User < ActiveRecord::Base

  validates :spotify_id, presence: true, uniqueness: true
  validates :email, uniqueness: true

  def admin?
    role == "admin"
  end
end
