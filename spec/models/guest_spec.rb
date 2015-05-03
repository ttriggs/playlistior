require 'rails_helper'

describe Guest do
  let(:guest) { FactoryGirl.build(:guest) }

  describe "#admin?" do
    it "returns false always" do
      expect(guest.admin?).to_not be
    end
  end

  describe "#guest?" do
    it "returns true always" do
      expect(guest.guest?).to be
    end
  end

  describe "#role" do
    it "returns guest" do
      expect(guest.role).to eq("guest")
    end
  end

  describe "#image_link" do
    it "returns default profile image link" do
      expect(guest.image_link).to eq("/assets/images/profile_default.png")
    end
  end

  describe "#name" do
    it "returns guest" do
      expect(guest.name).to eq("guest")
    end
  end

end
