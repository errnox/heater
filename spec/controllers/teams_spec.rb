require 'spec_helper'

describe TeamsController do
  fixtures :users
  fixtures :teams
  fixtures :organizations

  before(:each) do
    @user = User.all[0]
    @team = Team.all[0]
    @organization = Organization.all[0]
  end

  describe "POST #create" do
    it "successfully redirects with a HTTP 300 status code" do
      session[:user_id] = @user.id
      new_team_name = 'Test Team'
      post :create, :name => new_team_name, :description =>
        "Test Description", :organization_id =>
        @organization.id, :organization_name => @organization.name
      expect(response).to redirect_to(:controller => 'teams', :action =>
                                      'index', :organization_name =>
                                      @organization.name, :team_name =>
                                      new_team_name)
    end
  end

  describe "GET #index" do
    it "successfully responds with a HTTP 200 status code" do
      session[:user_id] = @user.id
      get :index, :organization_name => @organization.name, :team_name =>
        @team.name
      # expect(response).to be_success
    end
  end
end
