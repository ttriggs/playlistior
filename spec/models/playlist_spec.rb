require 'rails_helper'

describe Playlist do
  describe "validations" do
    it { should  have_many(:genres) }
    it { should  have_many(:styles) }
    it { should  have_many(:tracks) }
    it { should  have_many(:follows) }
    it { should  have_many(:assignments) }
    it { should  belong_to(:user) }

    it { should validate_presence_of(:seed_artist) }
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:spotify_id) }
    it { should validate_presence_of(:link) }
  end
end
