require File.dirname(__FILE__) + '/../spec_helper'

describe RolesController do
  integrate_views

  def test_index_requires_admin
    get :index, :user_id => users(:manager)
    assert_redirected_to new_session_url
  end

  def test_index_displays_roles
    login_as_admin
    get :index, {:user_id => users(:manager)}
    assert_response :success
  end


  # Update
  
  def test_update_requires_admin
    post :update, :user_id => users(:testuser), :id => roles(:manager_role)
    assert_redirected_to new_session_url
  end

  def test_update_changes_role
    post :update, {:user_id => users(:testuser), :id => roles(:manager_role)}, admin_session
    assert_redirected_to user_roles_url(users(:testuser))
  end

  
  # Destroy

  def test_destroy_requires_admin
    post :destroy, :user_id => users(:manager), :id => roles(:manager_role)
    assert_redirected_to new_session_url
  end
  
  def test_destroy_removes_role
    post :destroy, {:user_id => users(:manager), :id => roles(:manager_role)}, admin_session
    assert_redirected_to user_roles_url(users(:manager))
  end


  private

  def admin_session
    {:user_id => users(:admin).id}
  end
end
