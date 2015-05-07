module SessionHelper

  def user_signed_in?
    !current_user.guest? && !need_token_refresh?
  end

  def current_user
    @current_user ||= User.fetch_or_build_user_for_view(session)
  end

  def set_current_user(user)
    @current_user = user
    session[:user_id] = user.id
  end
end
