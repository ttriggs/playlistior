require 'rails_helper'

describe PlaylistsController do
  describe 'get #index page' do
    it 'renders the index of playlists' do
      session[:user_id] = 1
      session[:token] = TokenFaker.get_fake_token

      get :index

      expect(response.status).to eq(302)
      # expect(response).to render_template(:index)
    end
  end
end


describe PlaylistsController do
  describe 'get #show page' do
    it 'responds with page of playlists' do
      playlist = MockPlaylist.create(30)
      session[:user_id] = playlist.user_id
      session[:token] = TokenFaker.get_fake_token

      get :show, id: playlist.id

      expect(response.status).to eq(200)
      expect(response).to render_template(:show)
    end
  end
end
