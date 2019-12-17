class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  def logged_in_user
    if !logged_in?
      store_location
      flash[:danger] = "Please login to continue."
      redirect_to login_path
    end
  end
end
