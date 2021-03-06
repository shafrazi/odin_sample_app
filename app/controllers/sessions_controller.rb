class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      if user.activated?
        log_in(user)
        if params[:remember_me] == "1"
          remember(user)
        else
          forget(user)
        end
        redirect_back_or user_path(user)
      else
        flash[:warning] = "Account not activated. Check your email for the activation link."
        redirect_to root_path
      end
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new"
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end
end
