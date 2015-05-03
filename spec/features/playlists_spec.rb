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


feature 'I can search playlists by genre' do
  context 'on #index page' do
    scenario 'click search by genre' do
      playlist = MockPlaylist.create(30)
      user = FactoryGirl.create(:user)
      page.set_rack_session(user_id: user.id)
      page.set_rack_session(token: TokenFaker.get_fake_token)

      visit playlists_path
      expect(page).to have_link("Search by Genre »")
      click_on("Search by Genre »", match: :first)
      save_and_open_page
      expect(page).to have_link("Rock")
    end
  end
end

# can't test expand playlist button:
# it uses APIWrap wich causes errors in test env.
# feature 'I can extend my playlist' do
#   context 'on #show page' do
#     scenario 'click extend button to extend playlist' do
#       playlist = MockPlaylist.create(Playlist::SONGS_LIMIT + 10)
#       page.set_rack_session(user_id: playlist.user_id)
#       page.set_rack_session(token: TokenFaker.get_fake_token)

#       visit playlist_path(playlist)
#       click_on("Extend")
#       expect(page).to have_content("Playlist created (updates may appear first in Spotify app :)")
#     end
#   end
# end

# feature 'I cannot extend my playlist indefinitely' do
#   context 'on #show page click extend button' do
#     scenario 'no new tracks saved to playlist, so I see error' do
#       playlist = MockPlaylist.create(Playlist::SONGS_LIMIT)
#       page.set_rack_session(user_id: playlist.user_id)
#       page.set_rack_session(token: TokenFaker.get_fake_token)

#       visit playlist_path(playlist)
#       click_on("Extend")
#       expect(page).to have_content("Sorry no more tracks found for this playlist")
#     end
#   end
# end
