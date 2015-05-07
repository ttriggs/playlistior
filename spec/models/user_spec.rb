require 'rails_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }

  describe "validations" do
    it { should have_many(:playlists) }
    it { should have_many(:follows) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:spotify_id) }
    it { should validate_uniqueness_of(:spotify_id) }
    it { should validate_presence_of(:spotify_link) }

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

  describe ".find_or_create_from_auth" do
    it "saves or finds by auth" do
      auth = OmniauthMock.valid_credentials

      user = User.find_or_create_from_auth(auth)

      expect(user.spotify_id).to eq ('1234567')
      expect(user.name).to eq ('1337_haxor')
      expect(user.image).to eq ("www.myface.com/123.png")
      expect(user.email).to eq ("myface@hullo.com")
      expect(user.session_token).to eq ("token")
      expect(user.refresh_token).to eq ("refresh_token")
      expect(user.spotify_link).to eq ("my_spotify_link.com")
    end
  end

end
