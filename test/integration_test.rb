require 'test_helper'

class IntegrationTest < ActionDispatch::IntegrationTest

  def setup
    administrator_block = ->(id) {
      Administrator.find_by(id: id)
    }
    options = {
      administrator_block: administrator_block,
      login_path: '/admin_area/login'
    }
    AdminAreaController.has_admin_security options
    UsersController.has_admin_security options
    @administrator = Administrator.create!({email: "example@example.com"})
  end

  test "current_administrator is stored between controllers" do
    # login
    post '/admin_area/create_session', params: { email: @administrator.email }

    # access a protected method
    get '/admin_area/protected'
    assert_response :success

    # access a protected method on another controller
    get '/users/index'
    assert_response :success
  end

  test "administrator_block is called for each request" do
    administrator_block = ->(id) {
      Administrator.find_by(id: id, email: 'example@example.com')
    }
    options = {
      administrator_block: administrator_block,
      login_path: '/admin_area/login'
    }
    AdminAreaController.has_admin_security options
    UsersController.has_admin_security options

    # login
    post '/admin_area/create_session', params: { email: @administrator.email }

    # access a protected method
    get '/admin_area/protected'
    assert_response :success

    @administrator.update_attributes(email: 'example2@example.com')

    # access a protected method on another controller
    get '/users/index'
    assert_response 302
    assert @controller.current_administrator == :false
  end

end
