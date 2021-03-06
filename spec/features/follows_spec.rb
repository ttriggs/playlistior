require 'rails_helper'

feature 'can follow someone elses playlist' do
  context 'on #show page' do
    scenario 'see follow button for playlist' do
      playlist = MockPlaylist.create(30)
      user = FactoryGirl.create(:user)
      page.set_rack_session(user_id: user.id)
      page.set_rack_session(token: TokenFaker.get_fake_token)

      visit playlist_path(playlist)
      click_on("Follow")
      expect(page).to have_content("Playlist followed on Playlistior")
      expect(page).to have_button("Unfollow")
    end
  end
end

feature 'I can unfollow a followed playlist' do
  context 'on #show page' do
    scenario 'click unfollow button to remove my follow' do
      playlist = MockPlaylist.create(30)
      user = FactoryGirl.create(:user)
      page.set_rack_session(user_id: user.id)
      page.set_rack_session(token: TokenFaker.get_fake_token)

      visit playlist_path(playlist)
      click_on("Follow")
      click_on("Unfollow")
      expect(page).to have_content("Unfollowed playlist")
    end
  end
end

feature 'can see my followed playlist' do
  context 'on #index page' do
    scenario 'on #index' do
      playlist = MockPlaylist.create(30)
      user = FactoryGirl.create(:user)
      page.set_rack_session(user_id: user.id)
      page.set_rack_session(token: TokenFaker.get_fake_token)

      visit playlist_path(playlist)
      click_on("Follow")
      visit playlists_path
      expect(page).to have_content("Followed:")
      expect(page).to have_link(playlist.seed_artist.titleize)
    end
  end
end



