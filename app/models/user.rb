class User < ActiveRecord::Base
  has_many :playlists
  has_many :follows

  validates :spotify_id, uniqueness: { case_sensitive: false}
  validates :name, presence: true

  def self.get_user_data(session) ## IMPLEMENT
    access_token = session[:token][:number]
    params = { headers: { "Authorization" => "Bearer #{access_token}"} }
    HTTParty.get("https://api.spotify.com/v1/me", params)
  end


  def self.fetch_or_build_user(session) # user_data)
    user_data = get_user_data(session)
    user = User.find_or_initialize_by(spotify_id: user_data["id"] )
    unless user.in_db?
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

  def in_db?
    !name.nil?
  end

  def image_link
    image.nil? ? default_image : image
  end

  def default_image
    'default_images/profile_default.png'
  end

  def get_image(images)
    unless images.empty?
      images.first["url"]
    end
  end

end
