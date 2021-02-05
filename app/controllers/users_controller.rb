class UsersController < ApplicationController
  before_action :logged_in_user,  only:  [:index, :edit, :update, :destroy]
  before_action :correct_user,    only:  [:edit, :update]
  before_action :admin_user,      only:  [:destroy]

  def index
    @users = User.paginate(page: params[:page]) # @users = User.paginate (page: params[:page], per_page: 10, order: 'name ASC'
                                                # This will show 10 results per page.
                                                # User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate yourr account."
      redirect_to root_url
      # log_in @user
      # flash[:success] = "Welcome to the sample app!"
      # redirect_to @user
    else
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:succes] = "User deleted!"
    redirect_to users_url
  end

  def edit
  end

  def update
    if @user.update(user_params)
      # Handle a successful update
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      # flash[:error] = "Something went wrong"
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # Before Filters

    # Confirms a logged-in user
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) # @user == (current_user)
    end

    # Confirms an admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
