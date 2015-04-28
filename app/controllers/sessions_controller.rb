class SessionsController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :refresh_token_if_needed, except: [:new, :create]

  def new
    redirect_to spotify_auth_url
  end

  def create
    setup_new_tokens
    user = User.fetch_or_build_user(session)
    if user.save
      set_current_user(user)
      session[:user_id] = user.id
      flash[:info] = "Signed in successfully."
      redirect_to playlists_path
    else
      flash[:alert] = "Unable to sign in."
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:info] = "Signed out successfully."
    redirect_to root_path
  end
end
