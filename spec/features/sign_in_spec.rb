require "rails_helper"

feature "create/destroy session with valid credentials" do
  context "on home page" do
    before(:each) { OmniauthMock.setup_login }
    scenario "sign in at home page" do
      visit "/"
      click_on("Sign in with Spotify to begin")
      expect(page).to have_content("Signed in successfully.")
      expect(current_path).to eq(playlists_path)
      expect(page).to have_link("Sign Out")
    end

    scenario "sign out at home page" do
      visit "/"
      click_on("Sign in with Spotify to begin")
      click_on("Sign Out")
      expect(page).to have_link("Sign in with Spotify to begin")
      expect(page).to have_content("Signed out successfully.")
      expect(current_path).to eq(root_path)
    end
  end
end

feature "attempt to login with invalid credentials" do
  before(:each) do
    OmniauthMock.setup_invalid_login
  end
  context "on home page" do
    scenario "try to sign in" do
      visit "/"
      click_on("Sign in with Spotify to begin")
      expect(page).to have_content("Unable to Login to Spotify.")
      expect(page).to have_link("Sign in with Spotify to begin")
      expect(current_path).to eq(root_path)
    end
  end
  context "try to access playlists page" do
    scenario "bounced back to root path" do
      visit "/playlists"
      expect(current_path).to eq(root_path)
      expect(page).to have_content("Unable to Login to Spotify.")
      expect(page).to have_link("Sign in with Spotify to begin")
    end
  end
end

feature "attempt to login, but auth hash missing uid" do
  before(:each) do
    OmniauthMock.setup_no_uid_invalid_login
  end
  context "spotify passes back bad auth hash" do
    scenario "if missing uid" do
      visit "/"
      click_on("Sign in with Spotify to begin")
      expect(current_path).to eq(root_path)
      expect(page).to have_content("Unable to Login to Spotify.")
      expect(page).to have_link("Sign in with Spotify to begin")
    end
  end
end

