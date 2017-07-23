require 'spec_helper'

describe UserController do
  fixtures :users

  before(:each) do
    @user = User.all[0]
  end

  describe "GET #new" do
    it "should return successfully with a HTTP 200 code" do
      get :new
      expect(response).to be_success
    end

  end

  describe "POST #create" do
    it "should respond successfully with a HTTP 200 code" do
      post :create, :user => {:name => 'newuser', :email =>
        'newuser@example.com', :password => 'password'}
      expect(response).to redirect_to(:controller => 'sessions',
                                      :action => 'home')
    end

  end

  describe "POST #create" do
    it "should respond unsuccessfully with a HTTP 300 code" do
      post :create, :user => {:name => @user.name, :email => @user.email,
        :password => 'password'}
      expect(response).to redirect_to(:controller => 'user',
                                      :action => 'create')
    end
  end

  describe "GET #profile" do
    it "should redirect successfully with a HTTP 300 code" do
      get :profile, :name => @user.name
      expect(response).to be_redirect
    end
  end
end
