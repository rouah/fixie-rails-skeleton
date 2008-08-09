require File.dirname(__FILE__) + '/../../spec_helper'

describe User do

  # Associations

  def test_responds_to_associations    
    user = users(:manager)

    assert_association user, :has_many => :user_roles
    assert_association user, :has_many => :roles
  end


  # Validation

  def test_creates_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_validates_username_present
    user = create_user(:username => nil)
    assert user.errors.on(:username)
  end

  def test_validates_username_length
    user = create_user(:username => 'abc')
    assert user.errors.on(:username).include?('too short')

    user = create_user(:username => 'abc'*50)
    assert user.errors.on(:username).include?('too long')
  end

  def test_create_user_prohibits_funky_chars_in_username
    user = create_user(:username => "dere&s")
    assert user.errors.on(:username).include?('should use only')
  end

  def test_create_user_prohibits_spaces_in_username
    user = create_user(:username => "go mets")
    assert user.errors.on(:username).include?("should use only")
  end

  def test_validates_username_unique
    user = create_user(:username => users(:testuser).username)
    assert user.errors.on(:username).include?('already been taken')
  end

  def test_validates_email_present
    user = create_user(:email => nil)
    assert user.errors.on(:email)
  end

  def test_validates_email_unique
    user = create_user(:email => users(:testuser).email)
    assert user.errors.on(:email).include?('already been taken')
  end

  def test_create_user_requires_correctly_formatted_email
    user = create_user(:email => "derek@test")
    assert user.errors.on(:email).include?('is not a valid email address')
  end

  def test_validates_password_present
    user = create_user(:password => nil)
    assert user.errors.on(:password)
  end

  def test_validates_password_length
    user = create_user(:password => 'abc', :password_confirmation => 'abc')
    assert user.errors.on(:password).include?('too short')

    user = create_user(:password => 'abc'*50, :password_confirmation => 'abc'*50)
    assert user.errors.on(:password).include?('too long')
  end

  def test_validates_password_confirmation
    user = create_user(:password => "test", :password_confirmation => "asdf")
    assert user.errors.on(:password).include?('confirmation')
  end


  # Change pass

  def test_assigns_new_password
    users(:testuser).update_attributes(:password => 'new password', 
                                       :password_confirmation => 'new password')
    assert_equal users(:testuser), User.authenticate('testuser', 'new password')
  end

  def test_doesnt_rehash_existing_password
    users(:testuser).update_attributes(:username => 'newname')
    assert_equal users(:testuser), User.authenticate('newname', 'test')
  end


  # Roles
  
  def test_has_role_checks_for_role
    assert users(:manager).has_role?('manager')
    assert !users(:testuser).has_role?('manager')
  end
  
  def test_adds_role
    users(:testuser).add_role('manager')

    assert users(:testuser).reload.has_role?('manager')
  end


  # Authenticate

  def test_authenticates_user
    assert_equal users(:testuser), User.authenticate('testuser', 'test')
  end

  def test_authenticate_fails_with_invalid_username
    assert_nil User.authenticate('wrong_user', 'testing')
  end
  
  def test_authenticate_fails_with_invalid_pass
    assert_nil User.authenticate('testuser', 'wrong_pass')
  end


  # Remember me

  def test_should_set_remember_token
    users(:testuser).remember_me
    assert_not_nil users(:testuser).remember_token
    assert_not_nil users(:testuser).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:testuser).remember_me
    assert_not_nil users(:testuser).remember_token
    users(:testuser).forget_me
    assert_nil users(:testuser).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:testuser).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:testuser).remember_token
    assert_not_nil users(:testuser).remember_token_expires_at
    assert users(:testuser).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:testuser).remember_me_until time
    assert_not_nil users(:testuser).remember_token
    assert_not_nil users(:testuser).remember_token_expires_at
    assert_equal users(:testuser).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:testuser).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:testuser).remember_token
    assert_not_nil users(:testuser).remember_token_expires_at
    assert users(:testuser).remember_token_expires_at.between?(before, after)
  end


  # Lost Password

  def test_find_for_forgot_doesnt_find_unverified_users
    assert_not_nil User.find_for_forget(users(:forgot_pass).email)
    assert_nil User.find_for_forget(users(:unverified).email)
  end

  def test_user_forgot_password_generates_reset_code
    user = users(:testuser)
    user.forgot_password

    assert user.forgot_password?
    assert user.reload.password_reset_code.length > 20
  end

  def test_assigning_new_password_empties_pass_reset_code
    user = users(:forgot_pass)
    assert_not_nil user.password_reset_code

    user.update_attributes(:password => "asdf", :password_confirmation => "asdf")
    assert_nil user.reload.password_reset_code
  end


  # Email Verification

  def test_initializes_activation_code_upon_creation
    user = create_user
    assert_not_nil user.activation_code
  end

  def test_activate_verifies_user
    user = users(:unverified)
    assert !user.active?

    user.activate!
    assert user.reload.active?
    assert_nil user.reload.activation_code    
  end


  private

  def create_user(options = {})
    record = User.new({ :username => 'jlebowski',
                        :email    => 'jeff.lebowsky@example.com', 
                        :password => 'thedude', 
                        :password_confirmation => 'thedude' }.merge(options))
    record.save
    record
  end
end
