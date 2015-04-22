class Genre < ActiveRecord::Base
  has_many :playlists, through: :styles
  has_many :styles
  belongs_to :group

  def group_color
    rgb = group.rgb.tr('()','').split(" ")
    red = 114
    green = 147 + (rgb[1].to_i/5)
    blue = 0
    [red, green, blue].join(", ")
  end
end
