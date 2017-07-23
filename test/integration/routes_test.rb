require 'test_helper'

class RoutesTest < ActionController::TestCase
  # Signup
  test "get signup" do
    assert_generates('/signup', {:controller => 'user', :action => 'new'})
    assert_recognizes({:controller => 'user', :action => 'new'}, '/signup')
  end

  test "post signup" do
    assert_generates('/signup', {:controller => 'user', :action =>
                       'create'})
  end

  # Login
  test "get login" do
    assert_generates('/login', {:controller => 'sessions', :action =>
                       'login'})
    assert_recognizes({:controller => 'sessions', :action => 'login'},
                      '/login')
  end

  test "post login" do
    assert_generates('/login', {:controller => 'sessions', :action =>
                       'login'})
  end
end
