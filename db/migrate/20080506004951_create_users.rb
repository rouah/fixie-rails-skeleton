class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string   :username,            :null => false
      t.string   :email,               :null => false
      t.string   :crypted_password,    :null => false, :limit => 40
      t.string   :salt,                :null => false, :limit => 40
      t.string   :password_reset_code, :limit => 40
      t.string   :activation_code,     :limit => 40
      t.datetime :activated_at
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :ip_address
      t.boolean  :enabled,          :default => true
      t.timestamps
    end

    # Be sure to change the password 
    User.create(:username => "admin", 
                :email    => "admin@example.com",
                :password => "admin", 
                :password_confirmation => "admin").send(:activate!)
  end

  def self.down
    drop_table :users
  end
end
