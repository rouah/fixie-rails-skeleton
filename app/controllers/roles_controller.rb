class RolesController < ApplicationController
  before_filter :admin_required  
  before_filter :find_user
  before_filter :find_role, :only => [:update, :destroy]

  def index
    @roles = Role.find(:all)
  end

  def update
    unless @user.has_role?(@role.name)
      @user.roles << @role 
    end
    redirect_to user_roles_url(@user)
  end
  
  def destroy
    if @user.has_role?(@role.name)
      @user.roles.delete(@role) 
    end
    redirect_to user_roles_url(@user)
  end


  private

  def find_user
    @user = User.find(params[:user_id])
  end

  def find_role
    @role = Role.find(params[:id])
  end
end
