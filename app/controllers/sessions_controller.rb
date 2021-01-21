class SessionsController < ApplicationController
  def new

  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password]) # idem user && user.authenticate(params[:session][:password])
      # Log the user and redirect to the user's show page
      log_in user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination' # not quite right
      render 'new'
    end
  end

  def destroy
  end
end
