require 'test_helper'

class UserControllerTest < ActionController::TestCase
  setup do
    @user = User.all[0]
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
    post :create, :user => {:name => 'newuser', :email =>
      'newuser@example.com', :password => 'password'}
    assert_response :redirect
    assert_equal("Welcome! You have successfully authenticated.",
                 flash[:notice])
  end

  test "should get create unsuccessfully" do
    post :create, :user => {:name => @user.name, :email => @user.email,
      :password => 'password'}
    assert_response :redirect
    assert_equal 'Username not available.', flash[:notice]
  end
end
