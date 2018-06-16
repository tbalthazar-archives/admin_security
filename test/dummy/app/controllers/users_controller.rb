class UsersController < ApplicationController
  has_admin_security :login_path => "/admin_area/login"
  before_action :login_required

  def index
    render plain: "hey"
  end

end
