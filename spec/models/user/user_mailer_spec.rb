require File.dirname(__FILE__) + '/../../spec_helper'

describe UserMailer do

  before(:each) do
    @user = users(:testuser)
    ActionMailer::Base.delivery_method    = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries         = []
  end
  
  def test_deliver_signup
    UserMailer.deliver_signup(@user)
    assert !ActionMailer::Base.deliveries.empty?
  
    sent = ActionMailer::Base.deliveries.first
    assert_equal [@user.email], sent.to
    assert_match "verify membership", sent.subject
    assert_match @user.username, sent.body
  end

  def test_deliver_lost_password
    UserMailer.deliver_lost_password(@user)
    assert !ActionMailer::Base.deliveries.empty?
  
    sent = ActionMailer::Base.deliveries.first
    assert_equal [@user.email], sent.to
    assert_match "change password", sent.subject
    assert_match @user.username, sent.body
  end
  
  def test_deliver_resend_activation
    UserMailer.deliver_resend_activation(@user)
    assert !ActionMailer::Base.deliveries.empty?
  
    sent = ActionMailer::Base.deliveries.first
    assert_equal [@user.email], sent.to
    assert_match "verify membership", sent.subject
    assert_match @user.username, sent.body
  end
  
  
end
