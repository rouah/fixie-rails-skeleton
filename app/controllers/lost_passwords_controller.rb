class LostPasswordsController < ApplicationController
  before_filter :find_user, :only => [:edit, :update]

  # Enter email address to recover password 
  def new
    render
  end

  # Forgot password action
  def create
    if @user = User.find_for_forget(params[:email])
      @user.forgot_password
      flash[:error] = "A password reset link has been sent to your email address."
      redirect_to new_session_url

    else
      flash.now[:error] = "Could not find a user with that email address."
      render :action => 'new'
    end  
  end

  # Change to a new password
  def edit
    redirect_to new_lost_password_url unless @user
  end

  # update the new pass
  def update
    redirect_to new_lost_password_path and return unless @user

    # pass is blank
    if params[:user][:password].blank?
      flash[:error]= ["Please enter a new password."]
      render :action => "edit"

    # success
    elsif @user.update_attributes(params[:user])
      flash[:notice] = "Password changed successfully. Please sign in. "
      redirect_to new_session_url

    # save errors
    else
      render :action => "edit"
    end
  end
  
  private
  
  def find_user
    @user = User.find_by_password_reset_code(params[:id])    
  end
end
