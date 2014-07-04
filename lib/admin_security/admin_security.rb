module AdminSecurity
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def has_admin_security(options={})
      cattr_accessor :options
      self.options = options

      include AdminSecurity::InstanceMethods
    end
  end

  module InstanceMethods
    # Filter method to enforce a login requirement.
    def login_required
      logged_in? || access_denied
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:admin][:return_to] || default)
      session[:admin][:return_to] = nil
    end

   # Store the given administrator in the session.
    def current_administrator=(new_administrator)
      new_administrator_is_invalid = (new_administrator.nil? || new_administrator.is_a?(Symbol))
      session[:admin]||={}
      session[:admin][:administrator_id] = new_administrator_is_invalid ? nil : new_administrator.id
      @current_administrator = new_administrator
    end
   
    # --- used in views too
  
    # Accesses the current administrator from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_administrator
      @current_administrator ||= (login_from_session || :false)
    end
    
    # Returns true or false if the administrator is logged in.
    # Preloads @current_administrator with the administrator model if they're logged in.
    def logged_in?
      current_administrator != :false
    end
 
    # Redirect as appropriate when an access request fails.
    def access_denied
      store_location
      flash[:alert] = "You must be logged in to access this area."
      redirect_to self.class.options[:login_path]
      false
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:admin]||={}
      session[:admin][:return_to] = request.fullpath
    end
   
    # Called from #current_administrator.
    # First attempt to login by the administrator id stored in the session.
    def login_from_session
      session[:admin]||={}
      if session[:admin][:administrator_id]
        self.current_administrator = Administrator.find_by_id(session[:admin][:administrator_id])
      end
    end
   
  end

end

ActionController::Base.send :include, AdminSecurity
