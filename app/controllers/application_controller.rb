class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionHelper
  include TokenHelper
  include PlaylistHelper

  def authenticate_user!
    unless user_signed_in?
      flash[:notice] = "You must log in before continuing"
      redirect_to new_session_path
    end
  end
end
