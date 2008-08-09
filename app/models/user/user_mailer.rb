class UserMailer < ActionMailer::Base
  def signup(user)
    setup_email(user)
    @subject += 'Action Required to verify membership'
  end
  
  def lost_password(user)
    setup_email(user)
    @subject += "Action required to change password"
  end

  def resend_activation(user)
    setup_email(user)
    @subject += 'Action Required to verify membership'
  end


  protected

  def setup_email(user)
    @recipients  = user.email
    @from        = "verify@example.com"
    @subject     = "example.com "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
