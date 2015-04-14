module SessionHelper

  def authenticate_user!
    unless user_signed_in?
      # redirect_to new_session_path
      flash[:notice] = "You must log in before continuing"
    end
  end

  def user_signed_in?
    current_user && session[:token]["number"]
  end

  def current_user
    user = User.find_by(id: session[:user_id])
    user.nil? ? false : user
  end

  def get_user_data
    access_token = session[:token][:number]
    params = { headers: { "Authorization" => "Bearer #{access_token}"} }
    HTTParty.get("https://api.spotify.com/v1/me", params)
  end
end
