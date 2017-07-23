require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  setup do
    @user = User.all[0]
  end

  # The other `if'-branch is covered by actual public-facing methods with
  # according routes.
  test "should authenticate user" do
    session[:user_id] = @user.id
    assert_equal true, @controller.send(:authenticate_user)
  end

  # The other `if'-branch is covered by actual public-facing methods with
  # according routes.
  test "should save login state" do
    assert_equal true, @controller.send(:save_login_state)
  end
end
