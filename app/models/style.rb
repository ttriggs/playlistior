class Style < ActiveRecord::Base
  belongs_to :playlist
  belongs_to :genre

  validates :playlist, uniqueness: { scope: :genre }
end
