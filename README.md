# AdminSecurity

## Installation
```
gem 'admin_security', :git => 'https://github.com/tbalthazar/admin_security'
```

## Usage
You might want to have an `Administrator` model.

In the controller :
```
class Admin::AdminAreaController < ApplicationController
  has_admin_security :login_path => Rails.application.routes.url_helpers.new_admin_session_path
  before_filter :login_required
  layout 'admin'

end


class Admin::SessionsController < Admin::AdminAreaController
  before_filter :login_required, :except => [:new, :create]
  
  def new
  end
  
  def create
    self.current_administrator = Administrator.authenticate(params[:email], params[:password])
    if logged_in?
      redirect_back_or_default(admin_root_path)
      flash[:notice] = "Logged in successfully"
    else
      flash[:alert] = "Login and/or password are incorrect. Please try again."
      render :action => 'new'
    end
  end
  
  def destroy
    session[:admin] = nil
    flash[:notice] = "You have been logged out."
    redirect_to new_admin_session_path
  end
  
end
```

In the views :
```
<% if logged_in? %>
  Welcome <%= current_administrator.name %>.
<% end %>
```

## License
This project rocks and uses MIT-LICENSE.
