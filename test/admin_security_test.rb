require 'test_helper'

class AdminSecurityTest < ActionController::TestCase #ActiveSupport::TestCase

  def setup
    @controller = AdminAreaController.new
    @administrator = Administrator.create!({email: "example@example.com"})
  end

  test "truth" do
    assert_kind_of Module, AdminSecurity
  end

  test "setting and getting the current administrator" do
    get :index
    assert @controller.current_administrator==:false, "current_administrator should be nil but is #{@controller.current_administrator}"
    @controller.current_administrator = @administrator 
    assert @controller.current_administrator==@administrator
  end

  test "logged_in? returns false" do
    get :index
    assert @controller.logged_in? == false, "logged_in? should be false, but is : #{@controller.logged_in?}"
  end

  test "logged_in? returns true" do
    get :index
    @controller.current_administrator = @administrator 
    assert @controller.logged_in? == true, "logged_in? should be true, but is : #{@controller.logged_in?}"
  end

  test "login_from_session" do
    get :index
    assert @controller.logged_in? == false, "logged_in? should be false, but is : #{@controller.logged_in?}"
    session[:admin][:administrator_id] = @administrator.id 
    @controller.login_from_session
    assert @controller.logged_in? == true, "logged_in? should be true, but is : #{@controller.logged_in?}"
  end

  test "login_required redirects to login page" do
    get :protected
    assert_redirected_to :action => :login
  end

  test "login_required doesn't redirect when logged in" do
    get :index
    @controller.current_administrator = @administrator
    get :protected
    assert_response :success
  end

end
