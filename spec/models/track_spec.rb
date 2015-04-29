require 'rails_helper'

describe Track do
  describe "validations" do
    it { should  have_many(:playlists) }
    it { should  have_many(:assignments) }

    it { should validate_presence_of(:artist_name) }

    subject { FactoryGirl.build(:track) }
    it { should validate_uniqueness_of(:echonest_id) }
    it { should validate_presence_of(:spotify_id) }

    it { should validate_inclusion_of(:mode).in_range(0..1) }
    it { should validate_numericality_of(:key) }
    it { should validate_numericality_of(:tempo) }
    it { should validate_numericality_of(:energy) }
    it { should validate_numericality_of(:liveness) }
    it { should validate_numericality_of(:danceability) }
    it { should validate_numericality_of(:time_signature) }
  end
end
