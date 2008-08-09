ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.global_fixtures = :users, :roles, :user_roles
end

def login_as_admin
  @controller.send :current_user=, users(:admin) 
end

include AuthenticatedTestHelper

def assert_association(object, association)
  # specified class_name
  klass = association.delete(:class_name) if association.include?(:class_name)

  # type and name of association
  type, name = association.keys.first, association.values.first

  # belongs_to => :object || has_one => :object
  if [:belongs_to, :has_one].include?(type)
    klass = (klass || name.to_s.classify).constantize
    assert_kind_of klass, object.send(name)

    # has_many => :objects
  elsif [:has_many, :has_and_belongs_to_many].include?(type)
    klass = (klass || name.to_s.singularize.classify).constantize
    object.send(name).each {|obj| assert_kind_of klass, obj }
    assert object.send(name).size > 0

    # invalid 
  else 
    raise "Invalid option given for association in assert_association"
  end
end
