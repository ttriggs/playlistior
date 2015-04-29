require 'rails_helper'

describe User do
  describe "validations" do
    it { should  have_many(:playlists) }
    it { should  have_many(:follows) }

    it { should have_valid(:name).when('red') }
    it { should_not have_valid(:name).when(nil) }

    subject { FactoryGirl.build(:user) }
    it { should validate_uniqueness_of(:spotify_id).case_insensitive }
  end
end
