# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password


  protected 

  def credentials
    creds = {}
    authenticate_with_http_basic do |name,password|
      creds[:name]     = name
      creds[:password] = password
    end
    creds
  end

  def build_filter(param_name)
    if ( params[param_name] )
      @filter ||= {}
      @filter[param_name] = params[param_name]
    end
  end

end
