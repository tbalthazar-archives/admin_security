class AdminAreaController < ApplicationController
  #has_admin_security :login_path => url_for(:action => :login)
  has_admin_security :login_path => "/admin_area/login"
  before_filter :login_required, :only => [:protected]

  def index
  end

  def protected
  end

  def login
  end

end
