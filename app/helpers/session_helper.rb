module SessionHelper

  def authenticate_user!
    unless user_signed_in?
      flash[:notice] = "You must log in before continuing"
      redirect_to new_session_path
    end
  end

  def user_signed_in?
    current_user && !need_token_refresh?
  end

  def current_user
    if session[:user_id].nil?
      false
    else
      @user = User.find(session[:user_id])
    end
  end

  def admin?
    current_user.role == "admin"
  end
end
