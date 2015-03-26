require 'test_helper'

class IntegrationTest < ActionDispatch::IntegrationTest

  def setup
    @administrator = Administrator.create!({email: "example@example.com"})
  end

  test "current_administrator is stored between controllers with json serializer" do
    # login
    post '/admin_area/create_session', { email: @administrator.email }

    # access a protected method
    get '/admin_area/protected'
    assert_response :success

    # access a protected method on another controller
    get '/users/index'
    assert_response :success
  end

end
