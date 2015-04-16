class Group < ActiveRecord::Base
  has_many :genres
  has_many :tracks

end
