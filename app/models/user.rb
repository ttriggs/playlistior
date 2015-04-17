class User < ActiveRecord::Base
  has_many :playlists

  validates :spotify_id, uniqueness: { case_sensitive: false}
  validates :name, presence: true

  def image_link
    image.nil? ? default_image : image
  end

  def default_image
    'default_images/profile_default.png'
  end

end
