class User < ActiveRecord::Base
  PER_PAGE = 20

  # protect attributes
  attr_accessible :username, :email, :password, :password_confirmation
  attr_accessor :password

  # associations
  has_many :user_roles
  has_many :roles, :through => :user_roles

  # validation
  validates_length_of       :username, :in => 4..40
  validates_uniqueness_of   :username, :case_sensitive => false
  validates_format_of       :username, :with => /\A\w[\w\.\-_@]+\z/,
                                       :message => "should use only letters, numbers, and .-_@ please."

  validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email, :with => /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,6})\z/i,
                                    :message => "is not a valid email address"

  validates_length_of       :password, :in => 4..40, :if => :password_required?
  validates_confirmation_of :password,               :if => :password_required?
  validates_presence_of     :password_confirmation,  :if => :password_required?

  # callback filters
  before_save   :encrypt_password
  before_create :make_activation_code 

  
  # Roles

  def has_role?(role)
    self.roles.count(:conditions => ['name = ?', role]) > 0
  end

  def add_role(role)
    return if self.has_role?(role)
    self.roles << Role.find_by_name(role)
  end


  # Authentication
  
  # users can login without being "activated", but should display a warning
  def self.authenticate(username, password)
    user = find_by_username(username) # need to get the salt
    user && user.authenticated?(password) ? user : nil
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    password_digest(password, salt)
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end


  # Remember Me

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  
  # Forgot Password

  # we can only send an e-mail to reset the pass of it's activated
  def self.find_for_forget(email)
    find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
  end

  # Set a temporary random string for this user. We can send the
  # user this temporary hash to login when they forget their pass.
  def forgot_password
    @forgotten_password = true
    self.update_attribute(:password_reset_code, self.class.make_token)
  end

  # used in observer
  def forgot_password?
    @forgotten_password
  end


  # Email verification

  # existence of activation code means they have not activated yet
  def active?
    activation_code.nil?
  end

  def activate!
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end
  
  def send_activation!
    @resend_activation = true
    save(false)
  end

  # used in observer
  def resend_activation?
    @resend_activation
  end


  protected

  def password_required?
    crypted_password.blank? || !password.blank?
  end


  # Callback filters

  def encrypt_password
    return if password.blank?
    self.salt = self.class.make_token if new_record?
    self.crypted_password = encrypt(password)

    # if we've successfully encrypted the new pass
    self.password_reset_code = nil
  end

  def make_activation_code
    self.activation_code = self.class.make_token unless activated_at
  end


  # Secure digests

  def self.password_digest(password, salt)
    digest = AUTH_SITE_KEY
    AUTH_DIGEST_STRETCHES.times do
      digest = secure_digest(digest, salt, password, AUTH_SITE_KEY)
    end
    digest
  end

  def self.secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def self.make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end
end
