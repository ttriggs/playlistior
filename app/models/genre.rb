class Genre < ActiveRecord::Base
  has_many :playlists, through: :styles
  has_many :styles

end
