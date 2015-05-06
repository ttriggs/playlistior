class User < ActiveRecord::Base
  has_many :playlists
  has_many :follows

  validates :spotify_id, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def self.find_or_create_from_auth(auth)
    user = User.find_or_create_by(spotify_id: auth.uid)

    user.email         = auth.info.email
    user.name          = auth.info.name || user.email
    user.image         = auth.info.image
    user.spotify_link  = auth.extra.raw_info.href
    user.session_token = auth.credentials.token
    user.refresh_token = auth.credentials.refresh_token
    user.save

    user
  end

  def self.fetch_or_build_user_for_view(session)
    if session[:token] && User.exists?(session[:user_id])
      User.find(session[:user_id])
    else
      session[:user_id] = nil
      Guest.new
    end
  end

  def image_link
    image.nil? ? default_image : image
  end

  def default_image
    '/assets/images/profile_default.png'
  end

  def get_image(images)
    unless images.empty?
      images.first["url"]
    end
  end

  def admin?
    role == "admin"
  end

  def guest?
    false
  end
end
