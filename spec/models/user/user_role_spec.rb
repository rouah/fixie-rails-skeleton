require File.dirname(__FILE__) + '/../../spec_helper'

describe UserRole do

  # Associations

  def test_responds_to_associations    
    user_role = user_roles(:manager)

    assert_association user_role, :belongs_to => :user
    assert_association user_role, :belongs_to => :role
  end
end
