require 'rails_helper'


feature 'follows' do
  context 'user on playlist show' do

    scenario 'I am notified of follow' do
      playlist = FactoryGirl.create(:playlist)

      visit playlists_path
      expect(page).to have_content(playlist.artist_name)
    end
  end
end
