class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name, :null => false
      t.datetime :created_at
    end

    # Make sure the role migration file was generated first    
    Role.create(:name => 'administrator')
  end

  def self.down
    drop_table :roles
  end
end
