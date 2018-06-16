class AdminAreaController < ApplicationController
  has_admin_security :login_path => "/admin_area/login"
  before_action :login_required, :only => [:protected, :also_protected]

  def index
  end

  def protected
  end

  def also_protected
  end

  def login
  end

  def create_session
    self.current_administrator = Administrator.find_by(email: params[:email])
    render plain: params.inspect
  end

end
