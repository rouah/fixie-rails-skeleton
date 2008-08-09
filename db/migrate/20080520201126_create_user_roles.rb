class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table :user_roles do |t|
      t.integer :role_id, :null => false
      t.integer :user_id, :null => false
      t.datetime :created_at
    end

    add_index :user_roles, :role_id
    add_index :user_roles, :user_id

    # add admin permission
    UserRole.create(:role_id => Role.find_by_name('administrator').id, 
                    :user_id => User.find_by_username('admin').id)
  end

  def self.down
    drop_table :user_roles
  end
end