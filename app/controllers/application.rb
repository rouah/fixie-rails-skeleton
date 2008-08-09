# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'acedc0dc860515e2ac57f8938294a053boogie'

  # global helper methods
  helper_method :admin?
  

  private

  def login_required
    unless logged_in?
      flash[:error] = "You must be logged in to perform this action."
      access_denied
    end
  end

  def admin_required
    unless admin?
      flash[:error] = "You do not have permission to perform this action."
      access_denied
    end
  end

  def admin?
    logged_in? && current_user.has_role?('administrator')
  end
end
