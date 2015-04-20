class Genre < ActiveRecord::Base
  has_many :playlists, through: :styles
  has_many :styles
  belongs_to :group

  def group_color
    rgb = group.rgb.tr('()','').split(" ")
    rgb[1] = 220
    rgb[0] = rgb[0].to_i - 30
    rgb[2] = rgb[2].to_i - 30
    rgb.join(", ")
  end

end
