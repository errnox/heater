require 'spec_helper'

describe SessionsController do
  fixtures :users

  before(:each) do
    @user = User.all[0]
    @user_password = 'password'
  end

  describe 'GET #login' do
    it 'should respond successfully with a HTTP 200 status code' do
      get :login
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #login' do
    it 'should respond unsuccessfully with a HTTP redirect' do
      post :login_attempt, :name_or_email => @user.name, :password =>
        'wrongpassword'
      expect(response).to redirect_to(:controller => 'sessions',
                                      :action => 'login')
      expect(flash[:notice]).to eq('Invalid credentials')
    end
  end

  describe "POST login_attempt" do
    it "should respond successfully with a HTTP 300 status code" do
      post :login_attempt, :name_or_email => @user.name, :password =>
        @user_password
      expect(response).to redirect_to(:controller => 'sessions',
                                      :action => 'home')
      expect(session[:user_id]).to eq(@user.id)
    end

    it "should respond unsuccessfully with a HTTP 300 status code" do
      post :login_attempt, :name_or_email => @user.name, :password =>
        'wrongpassword'
      expect(response).to redirect_to(:controller => 'sessions',
                                      :action => 'login')
    end
  end

  describe "POST logout" do
    it "should respond successfully with a HTTP 200 status code" do
      get :logout
      expect(response).to redirect_to(:controller => 'sessions',
                                      :action => 'login')
    end
  end

  describe "POST change_password" do
    it "should respond successfully with a HTTP 200 status code" do
      post :change_password, :name => @user.name, :old_password =>
        @user_password, :new_password => 'newpassword'
      expect(response).to redirect_to(:controller => 'sessions',
                                      :action => 'home')
    end
  end

  describe "POST change_password" do
    it "should respond unsuccessfully with a HTTP 300 status code" do
      post :change_password, :name => @user.name, :old_password =>
        'wrongpassword', :new_password => 'newpassword'
      expect(response).to redirect_to(:controller => 'sessions',
                                      :action => 'settings')
    end
  end

  describe "POST change_email" do
    it "should respond successfully with a HTTP 200 status code" do
      session[:user_id] = @user.id
      post :change_email, :new_email => 'newemail@example.com'
      expect(response).to redirect_to(:controller => 'sessions',
                                      :action => 'home')
    end
  end

  describe "POST change_email" do
    it "should respond unsuccessfully with a HTTP 300 status code" do
      session[:user_id] = @user.id
      post :change_email, :new_email => 'invalidemail'
      expect(response).to redirect_to(:controller => 'sessions',
                                      :action => 'profile')
    end
  end

  describe "POST home" do
    it "should respond successfully with a HTTP 200 status code" do
      session[:user_id] = @user.id
      get :home
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe "POST profile" do
    it "should respond successfully with a HTTP 200 status code" do
      session[:user_id] = @user.id
      get :profile
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe "POST settings" do
    it "should respond successfully with a HTTP 200 status code" do
      session[:user_id] = @user.id
      get :settings
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe "GET #organizations" do
    it "should respond with a HTTP 200 status code" do
      session[:user_id] = @user.id
      get :organizations
      expect(response).to be_success
    end
  end

  describe "GET #all_organizations" do
    it "should respond successfully with a HTTP 200 status code" do
      get :all_organizations
      expect(response). to be_success
    end
  end
end
