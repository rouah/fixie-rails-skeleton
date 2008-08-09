class Role < ActiveRecord::Base
  has_many :user_roles
  has_many :users, :through => :permissions
end
