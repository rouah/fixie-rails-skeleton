class UsersController < ApplicationController
  before_filter :login_required, :only => [:show, :edit, :update]
  before_filter :admin_required, :only => [:index, :destroy, :enable]

  before_filter :find_user, :only => [:show, :edit, :update, :destroy, :enable]
  before_filter :confirm_user_owns_record, :only => [:edit, :update]

  def index
    @users = User.paginate(:per_page => User::PER_PAGE, 
                           :page     => params[:page], 
                           :order    => "users.username")
  end
  
  def show
    render
  end

  def new
    @user = User.new
  end

  def create
    cookies.delete :auth_token

    @user = User.new(params[:user])
    @user.ip_address = request.remote_ip
    if @user.save
      flash[:notice] = "Your registration was successful."

      # sign in user
      self.current_user = @user
      redirect_back_or_default user_url(@user)

    # error creating session
    else
      render :action => 'new'
    end
  end
  
  def edit
    render
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Updated successfully."
      redirect_to user_url(@user)
    else
      render :action => "edit"
    end
  end

  # destroying actually disables the user
  def destroy
    @user = User.find(params[:id])
    if @user.update_attribute(:enabled, false)
      flash[:notice] = "User disabled"
    else
      flash[:error] = "There was a problem disabling this user."
    end
    redirect_to users_url
  end
  
  def enable
    if @user.update_attribute(:enabled, true)
      flash[:notice] = "User enabled"
    else
      flash[:error] = "There was a problem enabling this user."
    end
      redirect_to users_url
  end

  
  # Activation

  # If the user lost their activation e-mail, we can resend it
  def resend_activation
    current_user.send_activation!

    flash[:notice] = "Activation email delivered successfully."
    redirect_to user_url
  end

  # Registration confirmation
  def activate
    # already verified
    if logged_in? && current_user.active?
      flash[:notice] = "This account has already been verified."
      redirect_to user_url
      return
    end

    self.current_user = User.find_by_activation_code(params[:id]) unless params[:id].blank?
    if logged_in?
      current_user.activate!
      flash[:notice] = "Account verified successfully."
      redirect_back_or_default user_url(current_user)

    # invalid or no id
    else
      flash.now[:error] = "This is an invalid verification code."
    end
  end


  private

  def find_user
    @user = User.find(params[:id])
  rescue
    redirect_to admin? ? users_url : user_url(current_user)
  end

  def confirm_user_owns_record
    return if admin?
    redirect_to edit_user_url(current_user) if @user.id != current_user.id
  end
end
