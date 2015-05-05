class SessionsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy]

  def new
    redirect_to "/auth/spotify"
  end

  def create
    add_token_to_session(auth.credentials)
    session[:return_to] = request.referer
    user = User.find_or_create_from_auth(auth)
    if user.save
      set_current_user(user)
      flash[:info] = "Signed in successfully."
      redirect_to playlists_path
    else
      flash[:errors] = "Unable to Login to Spotify."
      redirect_to session[:return_to]
    end
  end

  def destroy
    session.clear
    flash[:info] = "Signed out successfully."
    redirect_to root_path
  end

  private

  def auth
    request.env['omniauth.auth']
  end
end
