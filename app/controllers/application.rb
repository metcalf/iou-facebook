# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  layout 'canvas'
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => '6a217e9bde19307d3907405b39d42fe4'
    
  
  prepend_before_filter :get_user, :set_flash

  if(ENV["RAILS_ENV"] != 'test')
    prepend_before_filter :ensure_application_is_installed_by_facebook_user, :ensure_authenticated_to_facebook
  end
    
  def set_flash
    flash[:warning] = params.has_key?(:warning) ? Array(params[:warning]) : []
    flash[:notice]  = params.has_key?(:notice)  ? Array(params[:notice])  : []
  end

  private
 
  def get_user
    @current_user = User.find_or_create_by_id(facebook_session.user.id)
    User.current_user = @current_user
  end

  
end
