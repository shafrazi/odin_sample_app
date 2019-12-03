class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    if !@user.activated?
      redirect_to root_path
    end
  end

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "User deleted!"
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    if !logged_in?
      store_location
      flash[:danger] = "Please login to continue."
      redirect_to login_path
    end
  end

  def correct_user
    @user = User.find(params[:id])
    if @user != current_user
      redirect_to root_path
    end
  end

  def admin_user
    if !current_user.admin?
      redirect_to root_path
    end
  end
end
