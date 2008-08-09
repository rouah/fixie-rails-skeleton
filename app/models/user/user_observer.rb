class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_signup(user)
  end

  def after_save(user)
    UserMailer.deliver_lost_password(user)     if user.forgot_password?
    UserMailer.deliver_resend_activation(user) if user.resend_activation?
  end
end
