class SessionsController < ApplicationController
  # login page
  def new
    render
  end

  # process login. Verify first that there is a valid username/password 
  # and then make sure they are verified to login
  def create
    user = User.authenticate(params[:username], params[:password])
    
    # valid account
    if user && user.enabled?
      self.current_user = user
      remember_user if params[:remember_me] == "1"
      flash[:notice] = "Signed in successfully"
      redirect_back_or_default user_url(current_user)

    # disabled user
    elsif user && !user.enabled
      flash.now[:error] = "Your account has been disabled."
      render :action => "new"
      
    # invalid username/pass
    else
      flash.now[:error] = "Username/Password was not found. If you have forgot your " + 
              "password click <a href=\"#{url_for new_lost_password_path}\">here</a>" 
      render :action => "new"
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session

    flash[:notice] = "Signed out successfully."
    redirect_to new_session_url
  end  
end
