require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @user = User.all[0]
    # By convention, the test users `red' and `blue' both have the password
    # `password'. Only the encrypted one is saved in the test DB, though.
    # Hence it needs to be hardcoded here.
    @user_password = 'password'
  end

  test "should get login" do
    get :login
    assert_response :success
  end

  test "should post login attempt successfully" do
    post :login_attempt, :name_or_email => @user.name, :password =>
      @user_password
    assert_response :redirect
    assert_equal @user.id, session[:user_id]
  end

  test "should post login attempt unsuccessfully" do
    post :login_attempt, :name_or_email => @user.name, :password =>
      'wrongpassword'
    assert_response :success
    assert_equal 'Invalid credentials', flash[:notice]
  end

  test "should get logout" do
    get :logout
    assert_equal nil, session[:user_id]
    assert_response :redirect
  end

  test "should post change password successfully" do
    post :change_password, :name => @user.name, :old_password =>
      @user_password, :new_password => 'newpassword'
    assert_response :redirect
    assert_equal('Your password has been changed successfully.',
                 flash[:notice])
  end

  test "should post change password unsuccessfully" do
    post :change_password, :name => @user.name, :old_password =>
      'wrongpassword', :new_password => 'newpassword'
    assert_response :redirect
    assert_equal('You are not authorized.', flash[:notice])
  end

  test "should post change email successfully" do
    session[:user_id] = @user.id
    post :change_email, :new_email => 'newemail@example.com'
    assert_response :redirect
    assert_equal('Your email address has been changed successfully.',
                 flash[:notice])
  end

  test "should post change email unsuccessfully" do
    session[:user_id] = @user.id
    post :change_email, :new_email => 'invalidemail'
    assert_response :redirect
    assert_equal('Not a valid email address.', flash[:notice])
  end

  test "should get home" do
    get :home, nil, {:user_id => @user.id}
    assert_response :success
  end

  test "should get profile" do
    get :profile, nil, {:user_id => @user.id}
    assert_response :success
  end

  test "should get settings" do
    get :settings, nil, {:user_id => @user.id}
    assert_response :success
  end

end
