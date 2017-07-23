require 'spec_helper'

describe EventsController do
  fixtures :events
  fixtures :teams
  fixtures :users
  fixtures :metric_types
  fixtures :organizations

  before(:each) do
    @organization = Organization.all[0]
    @team = Team.all[0]
    @user = User.all[0]
    @metric_types = []
    3.times do |i|
      @metric_types << {:name =>
        "Test Metric Type \##{i + 1}", :description =>
        "This is Test Metric Type \##{i + 1}."}
    end
  end

  describe "POST #new" do
    it "should respond with a HTTP 200 status code" do
      session[:user_id] = @user.id
      post :new, :name => 'Test Event', :description =>
        'This is Test Event.', :team_id => @team.id, :annotation =>
        'No annotation', :metricTypes =>
        @metric_types, :organization_name =>
        @organization.name, :team_name => @team.name
      expect(response).to be_success
    end
  end
end
