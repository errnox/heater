require 'spec_helper'

describe OrganizationsController do
  fixtures :users
  fixtures :organizations

  before(:each) do
    @user = User.all[0]
    @organization = Organization.all[0]
  end

  describe "POST #create" do
    it "successfully redirects with a HTTP 300 status code" do
      session[:user_id] = @user.id
      organization_name = 'Test Organization'
      organization_description = 'This is a test description.'
      post :create, :name => organization_name, :description =>
        organization_description
      expect(response).to redirect_to(:controller =>
                                      'organizations',
                                      :action => 'index',
                                      :organization_name =>
                                      organization_name)
    end
  end

  describe "POST #create" do
    it "unsuccessfully redirects with a HTTP 300 status code" do
      session[:user_id] = @user.id
      # Invalid name
      post :create, :name => '', :description =>
        'This is a test description.'
      expect(response).to redirect_to(:controller =>
                                      'organizations',
                                      :action => 'create')
    end
  end

  describe "POST #create" do
    it "unsuccessfully redirects with a HTTP 300 status code" do
      post :create, :name => 'Test Organization', :description =>
        'This is a test description.'
      expect(response).to redirect_to(:controller =>
                                      'sessions', :action => 'login')
    end
  end

  describe "GET #index" do
    it "successfully responds with a HTTP 200 status code" do
      session[:user_id] = @user.id
      get :index, :organization_name => @organization.name
      expect(response).to be_success
    end
  end

  describe "GET #index" do
    it "unsuccessfully redirect with a HTTP 300 status code" do
      get :index, :organization_name => @organization.name
      expect(response).to be_redirect
    end
  end
end
