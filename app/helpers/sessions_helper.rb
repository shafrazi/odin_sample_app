module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  # returns the user currently logged in and nil if otherwise
  def current_user
    if @current_user.nil?
      @current_user = User.find_by(id: session[:user_id])
    else
      @current_user
    end
  end

  # returns true if a user is logged in and false otherwise
  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
