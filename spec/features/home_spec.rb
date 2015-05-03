require 'rails_helper'

feature 'view home page' do
  context 'got to root path' do
    scenario 'view login screen as visitor' do
      page.set_rack_session(user_id: nil)
      page.set_rack_session(token: nil)
      visit '/'

      expect(page).to have_link("Sign In")
      expect(page).to have_link("Sign in with Spotify to begin")
    end

    scenario 'view login screen as active user' do
      user = FactoryGirl.create(:user)
      page.set_rack_session(user_id: user.id)
      page.set_rack_session(token: TokenFaker.get_fake_token)
      visit '/'
      expect(page).to have_content("Signed in as #{user.name}")
      expect(page).to have_link("Sign Out")
    end
  end
end
