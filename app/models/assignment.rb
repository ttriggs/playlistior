class Assignment < ActiveRecord::Base
  belongs_to :playlist
  belongs_to :track

  validates :playlist, uniqueness: { scope: :track }

end
