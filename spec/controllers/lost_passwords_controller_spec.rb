require File.dirname(__FILE__) + '/../spec_helper'

describe LostPasswordsController do
  integrate_views
  before(:each) do
    # test out mail gets sent
    ActionMailer::Base.delivery_method    = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries         = []
  end


  # New

  def test_new_displays_form
    get :new
    assert_select "form"
  end
  
  
  # Create

  def test_create_redirects_to_login
    post :create, :email => users(:testuser).email
    assert_redirected_to new_session_url
  end
  
  def test_create_sends_notification_email
    post :create, :email => users(:testuser).email

    assert !ActionMailer::Base.deliveries.empty?
    sent = ActionMailer::Base.deliveries.first
    assert_match "change password", sent.subject
  end

  def test_create_with_invalid_email_shows_error
    post :create, :email => "asdf"
    assert_select "#message_box"
  end


  # Edit

  def test_edit_with_invalid_code_redirects_to_new
    get :edit, :id => "asdf"
    assert_redirected_to new_lost_password_url
  end

  def test_edit_with_valid_code_displays_form
    get :edit, :id => users(:testuser).password_reset_code
    assert_select "#user_password"
  end
  
  
  # Update
  
  def test_update_with_invalid_code_redirects_to_new
    post :update, :user => {:password => "newpass", 
                            :password_confirmation => "newpass"},
                  :id => "asdf"
    assert_redirected_to new_lost_password_url
  end

  def test_update_with_empty_pass_shows_error
    post :update, :user => {:password => "", 
                            :password_confirmation => ""}, 
                  :id => users(:testuser).password_reset_code
    assert_select "#message_box"
  end
  
  def test_update_with_invalid_pass_shows_error
    post :update, :user => {:password => "newpass", 
                            :password_confirmation => ""}, 
                  :id => users(:testuser).password_reset_code
    assert_select "#message_box"
  end
  
  def test_update_changes_password
    post :update, :user => {:password => "newpass", 
                            :password_confirmation => "newpass"}, 
                  :id => users(:testuser).password_reset_code
    assert_redirected_to new_session_url
  end
end
