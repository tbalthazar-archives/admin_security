require 'test_helper'

class AdminSecurityTest < ActionController::TestCase

  def setup
    administrator_block = ->(id) {
      Administrator.find_by(id: id)
    }
    cookie_auth_block = ->(auth_token) {
      Administrator.find_by(auth_token: auth_token)
    }
    options = {
      administrator_block: administrator_block,
      cookie_auth_block: cookie_auth_block,
      login_path: '/admin_area/login'
    }
    AdminAreaController.has_admin_security options
    
    email = "example@example.com"
    @auth_token = "fake-auth-token"
    @controller = AdminAreaController.new
    @administrator = Administrator.create!({email: email, auth_token: @auth_token})
  end

  def teardown
    session = nil
    @controller = nil
  end

  test "truth" do
    assert_kind_of Module, AdminSecurity
  end

  test "setting and getting the current administrator" do
    get :index
    assert_equal :false, @controller.current_administrator, "current_administrator should be :false but is #{@controller.current_administrator}"
    @controller.current_administrator = @administrator 
    assert_equal @administrator, @controller.current_administrator
  end

  test "setting current administrator without specifying an administrator block" do
    get :index
    AdminAreaController.options[:administrator_block] = nil
    assert_equal :false, @controller.current_administrator
    @controller.current_administrator = @administrator
    assert_equal :false, @controller.current_administrator, "current_administrator should be :false because the administrator_block failded"
  end

  test "setting current administrator which fails to pass the administrator block" do
    get :index
    administrator_block = ->(id) {
      return nil
    }
    AdminAreaController.options[:administrator_block] = administrator_block
    assert_equal :false, @controller.current_administrator
    @controller.current_administrator = @administrator
    assert_equal :false, @controller.current_administrator, "current_administrator should be :false because the administrator_block failded"
  end

  test "logged_in? returns false" do
    get :index
    assert_not @controller.logged_in?, "logged_in? should be false, but is : #{@controller.logged_in?}"
  end

  test "logged_in? returns true" do
    get :index
    @controller.current_administrator = @administrator 
    assert @controller.logged_in?, "logged_in? should be true"
  end

  test "logged_in? returns false if no administrator block is specified" do
    AdminAreaController.options[:administrator_block] = nil
    get :index
    @controller.current_administrator = @administrator 
    assert_not @controller.logged_in?, "logged_in? should return false because the administrator_block was not specified"
  end

  test "logged_in? returns false if administrator block fails" do
    administrator_block = ->(id) {
      return nil
    }
    AdminAreaController.options[:administrator_block] = administrator_block
    get :index
    @controller.current_administrator = @administrator 
    assert_not @controller.logged_in?, "logged_in? should return false because the administrator_block has failed"
  end

  test "login_from_session" do
    get :index
    session['admin'] = {}
    session['admin']['administrator_id'] = @administrator.id 
    assert @controller.logged_in?
  end

  test "login_from_session fails because no administrator block is given" do
    AdminAreaController.options[:administrator_block] = nil
    get :index
    session['admin']||={}
    session['admin']['administrator_id'] = @administrator.id 
    @controller.login_from_session
    assert_not @controller.logged_in?, "logged_in? should be false"
  end

  test "login_from_session fails because administrator returns nil" do
    administrator_block = ->(id) {
      return nil
    }
    AdminAreaController.options[:administrator_block] = administrator_block
    get :index
    session['admin']||={}
    session['admin']['administrator_id'] = @administrator.id 
    @controller.login_from_session
    assert_not @controller.logged_in?, "logged_in? should be false"
  end

  test "login_from_cookie" do
    cookies.signed[:auth_token] = @auth_token
    get :index
    assert @controller.logged_in?
  end

  test "login_from_cookie with custom cookies key" do
    AdminAreaController.options[:cookie_auth_key] = :funky_auth_key
    cookies.signed[:funky_auth_key] = @auth_token
    get :index
    assert @controller.logged_in?
  end

  test "login_from_cookie should fail if cookie_auth_block fails" do
    cookies.signed[:auth_token] = @auth_token + "modified"
    get :index
    assert_not @controller.logged_in?
  end

  test "login_from_cookie should fail if no cookie_auth_block is given" do
    cookies.signed[:auth_token] = @auth_token
    AdminAreaController.options[:cookie_auth_block] = nil
    get :index
    assert_not @controller.logged_in?
  end

  test "login_from_cookie should fail if no administrator block is given" do
    AdminAreaController.options[:administrator_block] = nil
    cookies.signed[:auth_token] = @auth_token
    get :index
    assert_not @controller.logged_in?
  end

  test "login_from_cookie should fail if administrator block fails" do
    administrator_block = ->(id) {
      return nil
    }
    AdminAreaController.options[:administrator_block] = administrator_block
    cookies.signed[:auth_token] = @auth_token
    get :index
    assert_not @controller.logged_in?
  end

  test "login_required redirects to login page" do
    get :protected
    assert_redirected_to action: :login
  end

  test "default flash message for access_denied" do
    get :protected
    assert_equal "You must be logged in to access this area.", flash[:alert]
  end

  test "custom flash message for access_denied" do
    custom_message = "custom message for access denied"
    AdminAreaController.has_admin_security access_denied_message: custom_message
    get :protected
    assert_equal custom_message, flash[:alert]
  end

  test "empty flash message for access_denied" do
    AdminAreaController.has_admin_security access_denied_message: nil
    get :protected
    assert_nil flash[:alert]
  end

  test "login_required redirects to root path if no login path given" do
    AdminAreaController.has_admin_security login_path: nil
    get :protected
    assert_redirected_to root_path
  end

  test "login_required doesn't redirect when logged in" do
    get :index
    @controller.current_administrator = @administrator
    get :protected
    assert_response :success
    get :also_protected
    assert_response :success
  end

end
