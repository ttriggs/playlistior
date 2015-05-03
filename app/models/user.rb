class User < ActiveRecord::Base
  has_many :playlists
  has_many :follows

  validates :spotify_id, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def self.fetch_or_build_user(session)
    user_data = get_user_data(session)
    user = User.find_or_initialize_by(spotify_id: user_data["id"] )
    unless user.persisted?
      user.email = user_data["email"]
      user.name  = user_data["display_name"] || user.email
      user.image = user.get_image(user_data["images"])
      user.country = user_data["country"]
      user.spotify_link = user_data["href"]
    end
    user.session_token = session[:token][:number]
    user.refresh_token = session[:token][:refresh]
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

  private

  def self.get_user_data(session)
    access_token = session[:token][:number]
    params = { headers: { "Authorization" => "Bearer #{access_token}"} }
    HTTParty.get("https://api.spotify.com/v1/me", params)
  end
end
