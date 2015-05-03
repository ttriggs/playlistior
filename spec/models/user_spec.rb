require 'rails_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }

  describe "validations" do
    it { should  have_many(:playlists) }
    it { should  have_many(:follows) }

    it { should have_valid(:name).when('red') }
    it { should_not have_valid(:name).when(nil) }

    subject { FactoryGirl.build(:user) }
    it { should validate_uniqueness_of(:spotify_id).case_insensitive }
  end

  describe "#get_image from spotify data" do
    spotify_data = [
                    {"url" => "http://fake/image.png"},
                    {"url" => "blah"}
                   ]
    it "returns first image in array if supplied one" do
      image = user.get_image(spotify_data)
      expect(image).to eq("http://fake/image.png")
    end
  end

  describe "#image_link" do
    it "returns user.image if one is saved" do
      user.image = "http://this/image/path.png"
      response = user.image_link
      expect(response).to eq("http://this/image/path.png")
    end

    it "returns #default_image if one is not saved to user.image" do
      user.image = nil
      response = user.image_link
      expect(response).to eq(user.default_image)
    end
  end

  describe ".fetch_or_build_user_for_view" do
    it "returns valid user if session token and user id in session" do
      user = FactoryGirl.create(:user)
      session = {}
      session[:user_id] = user.id
      session[:token] = TokenFaker.get_fake_token
      response = User.fetch_or_build_user_for_view(session)
      expect(response.class).to be(User)
      expect(response.name).to eq(user.name)
      expect(response.spotify_id).to eq(user.spotify_id)
    end

    it "else it returns Guest class instance" do
      session = {}
      session[:user_id] = nil
      session[:token] = nil
      response = User.fetch_or_build_user_for_view(session)
      expect(response.class).to be(Guest)
      expect(response.guest?).to be
    end
  end
end
