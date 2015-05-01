require 'rails_helper'

feature 'can view all created playlists' do
  context 'get #index page' do
    scenario 'see #index of playlists' do
      playlist = MockPlaylist.create(30)
      page.set_rack_session(user_id: playlist.user_id)
      page.set_rack_session(token: TokenFaker.get_fake_token)

      visit playlists_path
      expect(page).to have_link(playlist.seed_artist.titleize)
    end
  end
end

feature 'can view a specific playlist' do
  context 'get #show page' do
    scenario 'see #show for playlist' do
      playlist = MockPlaylist.create(30)
      page.set_rack_session(user_id: playlist.user_id)
      page.set_rack_session(token: TokenFaker.get_fake_token)

      visit playlist_path(playlist)
      expect(page).to have_content("Inspired by #{playlist.seed_artist.titleize}")
      expect(page).to have_content("This harmonic playlist visualized")
      expect(page).to have_button("Extend")
      expect(page).to have_link("Delete")
    end
  end
end

feature 'I can delete my playlist' do
  context 'on #show page' do
    scenario 'click delete button to remove playlist' do
      playlist = MockPlaylist.create(30)
      page.set_rack_session(user_id: playlist.user_id)
      page.set_rack_session(token: TokenFaker.get_fake_token)

      visit playlist_path(playlist)
      click_on("Delete")
      expect(page).to have_content("Playlist Deleted")
    end
  end
end

feature 'I cannot modify other users playlist' do
  context 'on #show page' do
    scenario 'click delete button to remove playlist' do
      playlist = MockPlaylist.create(30)
      user = FactoryGirl.create(:user)
      page.set_rack_session(user_id: user.id)
      page.set_rack_session(token: TokenFaker.get_fake_token)

      visit playlist_path(playlist)
      expect(page).to have_button("Follow")
      expect(page).to_not have_button("Extend")
      expect(page).to_not have_link("Delete")
    end
  end
end

