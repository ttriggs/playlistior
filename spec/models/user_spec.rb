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

  # describe ".fetch_or_build_user_for_view" do
  #   it "returns valid user if session token and user id in session" do
  #     user = FactoryGirl.create(:user)
  #     session[:user_id] = user.id
  #     session[:token] = TokenFaker.get_fake_token
  #     response = User.fetch_or_build_user_for_view
  #     expect(response.class).to be(User)
  #     expect(response.name).to eq(user.name)
  #     expect(response.spotify_id).to eq(user.spotify_id)
  #   end

  #   it "else it returns Guest class instance" do
  #     session[:user_id] = nil
  #     session[:token] = nil
  #     response = User.fetch_or_build_user_for_view
  #     expect(response.class).to be(Guest)
  #     expect(response.guest?).to be
  #   end
  # end


end
