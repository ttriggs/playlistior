require 'rails_helper'

feature 'view home page' do
  context 'got to root path' do
    scenario 'view login screen' do
      page.set_rack_session(user_id: nil)
      page.set_rack_session(token: nil)
      visit '/'

      expect(page).to have_link("Sign In")
      expect(page).to have_link("Sign in with Spotify to begin")
    end
  end
end
