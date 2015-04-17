class SessionsController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :refresh_token_if_needed, except: [:new, :create]

  def new
    redirect_to spotify_auth_url
  end

  def create
    setup_new_tokens
    user = User.fetch_or_build_user(session)
binding.pry if !user.valid?
    if user.save
      session[:user_id] = user.id
      flash[:info] = "Signed in successfully."
      redirect_to root_path
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

  private

  # def fetch_or_build_user(user_data)
  #   user = User.find_or_initialize_by(spotify_id: user_data["id"] )
  #   user.email = user_data["email"]
  #   user.name  = user_data["display_name"] || user.email
  #   user.image = get_image(user_data["images"])
  #   user.country = user_data["country"]
  #   user.spotify_link = user_data["href"]
  #   user
  # end

  # def get_image(images)
  #   unless images.empty?
  #     images.first["url"]
  #   end
  # end
end
