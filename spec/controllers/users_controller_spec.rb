require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  integrate_views

  before(:each) do
    # test out mail gets sent
    ActionMailer::Base.delivery_method    = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries         = []
  end

  # Index
  
  def test_index_requires_admin
    get :index, {}, default_session
    assert_redirected_to new_session_url
  end


  # New

  def test_new_displays_form
    get :new, {}, default_session
    assert_select "form.new_user"
  end


  # Create

  def test_create_inserts_user
    assert_difference 'User.count' do
      post :create, :user => create_user
    end
  end
  
  def test_create_sends_notification_email
    post :create, :user => create_user
    
    assert !ActionMailer::Base.deliveries.empty?
    sent = ActionMailer::Base.deliveries.first
    assert_match "verify membership", sent.subject
  end

  def test_create_redirects_to_user
    post :create, :user => create_user
    assert_redirected_to user_url(User.find_by_username('jlebowski'))
  end

  def test_create_starts_session
    post :create, :user => create_user
    assert_not_nil session[:user_id]
    assert_redirected_to user_url(User.find_by_username('jlebowski'))
  end

  def test_create_with_errors_renders_form
    post :create, :user => create_user(:username => '')
    assert_select "#message_box"
  end



  # Edit

  def test_edit_requires_owning_user
    get :edit, {:id => users(:manager).id}, default_session
    assert_redirected_to edit_user_path(users(:testuser))
  end

  def test_edit_displays_form_for_owning_user
    get :edit, {:id => users(:testuser).id}, default_session
    assert_select "form.edit_user"
  end
  
  def test_edit_displays_form_for_admin
    get :edit, {:id => users(:testuser).id}, admin_session
    assert_select "form.edit_user"
  end


  # Update

  def test_update_requires_owning_user
    post :update, {:id   => users(:manager).id, 
                   :user => {:username => 'edituser',   
                             :email    => 'edituser@example.com'}}, default_session
    assert_redirected_to edit_user_path(users(:testuser))
  end

  def test_update_updates_user_for_owning_user
    assert_difference 'User.find_all_by_username("edituser").length' do 
      post :update, {:id   => users(:testuser).id, 
                     :user => {:username => 'edituser',   
                               :email    => 'edituser@example.com',
                               :password => 'test', 
                               :password_confirmation => 'test'}}, default_session
      assert_redirected_to user_url(users(:testuser))
    end
  end

  def test_update_updates_user_for_admin
    assert_difference 'User.find_all_by_username("edituser").length' do 
      post :update, {:id   => users(:testuser).id, 
                     :user => {:username => 'edituser',   
                               :email    => 'edituser@example.com',
                               :password => 'test', 
                               :password_confirmation => 'test'}}, admin_session
      assert_redirected_to user_url(users(:testuser))
    end
  end
  
  def test_update_with_errors_renders_form
    post :update, {:id   => users(:testuser).id, 
                   :user => {:username => '',
                             :email    => 'edituser@example.com',
                             :password => 'test',
                             :password_confirmation => 'test'}}, admin_session
    assert_select "#message_box"
  end


  # Destroy/Enable

  def test_destroy_require_admin
    post :destroy, {:id => users(:testuser).id}, default_session
    assert_redirected_to new_session_url
  end
  
  def test_destroy_disables_user
    assert_difference 'User.find(:all, :conditions => {:enabled => true}).length', -1 do 
      post :destroy, {:id => users(:testuser).id}, admin_session
      assert_redirected_to users_url
    end
  end

  def test_enables_user
    assert_difference 'User.find(:all, :conditions => {:enabled => true}).size' do 
      post :enable, {:id => users(:disabled).id}, admin_session
      assert_redirected_to users_url
    end
  end


  # Activate
  
  def test_activate_redirects_if_already_verified
    login_as :testuser
    get :activate, :id => "asdf"
    assert_redirected_to user_url
  end

  def test_activate
    get :activate, :id => "5bf824fc1087f5af71d5a65b2a5dc76da0346321"
    assert_redirected_to user_url(users(:unverified))
  end

  def test_activate_displays_errors_for_invalid_code
    get :activate, :id => "asdf"
    assert_select "#message_box"
  end


  private

  def create_user(options = {})
    { :username => 'jlebowski', 
      :email    => 'jeff.lebowsky@example.com', 
      :password => 'thedude', 
      :password_confirmation => 'thedude' }.merge(options)
  end

  def default_session
    {:user_id => users(:testuser).id}
  end
  
  def admin_session
    {:user_id => users(:admin).id}
  end
end
