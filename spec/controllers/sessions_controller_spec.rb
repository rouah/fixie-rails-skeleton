require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  integrate_views

  def test_new_displays_form
    get :new
    assert_select "form.new_session"
  end

  def test_login_with_cookie
    users(:testuser).remember_me
    @request.cookies["auth_token"] = cookie_for(:testuser)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_fail_expired_cookie_login
    users(:testuser).remember_me
    users(:testuser).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:testuser)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_fail_cookie_login
    users(:testuser).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end


  # Create

  def test_login_redirects
    post :create, :username => 'testuser', :password => 'test'
    assert session[:user_id]
    assert_response :redirect
  end

  def test_login_requires_enabled_user
    post :create, :username => 'disabled', :password => 'test'
    assert_nil session[:user_id]
    assert_select "#message_box"
  end

  def test_failed_login_displays_error
    post :create, :username => 'testuser', :password => 'bad password'
    assert_nil session[:user_id]
    assert_select "#message_box"
  end

  def test_remember_me
    post :create, :username => 'testuser', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_not_remember_me
    post :create, :username => 'testuser', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end


  # Destroy

  def test_logout
    login_as :testuser
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  def test_delete_token_on_logout
    login_as :testuser
    get :destroy
    assert_equal @response.cookies["auth_token"], []
  end


  private

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
  
  def cookie_for(user)
    auth_token users(user).remember_token
  end
end
