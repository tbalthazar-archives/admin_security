module AdminSecurity
  extend ActiveSupport::Concern

  included do
    self.send :helper_method, :current_administrator, :logged_in?
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
      redirect_to(session['admin']['return_to'] || default)
      session['admin']['return_to'] = nil
    end

    # Store the given administrator in the session.
    def current_administrator=(new_administrator)
      session['admin']||={}
      session['admin']['administrator_id'] = nil
      @current_administrator = nil

      return nil if new_administrator.nil? || new_administrator.is_a?(Symbol)

      validated_administrator = validated_administrator(new_administrator.id)
      if validated_administrator
        session['admin']['administrator_id'] = validated_administrator.id
        @current_administrator = validated_administrator
      end

      return @current_administrator
    end
   
    # --- used in views too
  
    # Accesses the current administrator from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_administrator
      @current_administrator ||= (login_from_session || login_from_cookie || :false)
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
      login_path = self.class.options[:login_path] || root_path
      redirect_to login_path 
      false
    end

    # Store the URI of the current request in the session.
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session['admin']||={}
      session['admin']['return_to'] = request.fullpath
    end
   
    # Called from #current_administrator.
    # First attempt to login by the administrator id stored in the session.
    def login_from_session
      session['admin']||={}
      if session['admin']['administrator_id']
        return validated_administrator(session['admin']['administrator_id'])
      else
        return nil
      end
    end

    # Called from #current_administrator.
    def login_from_cookie
      cookie_auth_block = self.class.options[:cookie_auth_block]
      if cookie_auth_block.nil?
        return nil
      else
        self.current_administrator = cookie_auth_block.call
        return @current_administrator
      end
    end

    private

    # calls the administrator_block to validate the administrator
    def validated_administrator(administrator_id)
      administrator_block = self.class.options[:administrator_block]
      if administrator_block.nil?
        return nil
      else
        return administrator_block.call(administrator_id)
      end
    end
   
  end

end

ActionController::Base.send :include, AdminSecurity
