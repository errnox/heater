class MetricsController < ApplicationController
  before_filter :authenticate_user, :only => [:index]
  before_filter :save_login_state, :only => [:login, :login_attempt]

  def index
    @user_is_team_member = false
    @user = User.find_by_id session[:user_id]
    @organization =
      Organization.find_by_name deurlify(params[:organization_name])
    # @team =
    #   Team.find_by_name deurlify(params[:team_name])
    @team = nil
    Team.all.each do |team|
      if team.name == deurlify(params[:team_name]) &&
          team.organization_id == @organization.id
        @team = team
        @user_is_team_member = TeamMembership.find_by :team_id =>
          @team.id, :user_id => session[:user_id]
      end
    end
    @metric_types = []
    @event = Event.find_by_id params[:event_id] || nil
    MetricType.all.each do |metric_type|
      if metric_type.event_id == @event.id
        @metric_types << metric_type
      end
    end
    if @user_is_team_member
      render 'metrics/index'
    else
      render 'redirects/team_members'
    end
  end

  def new
    @message = ''
    params[:metrics].each do |mtrc|
      metric = Metric.find_or_initialize_by :name =>
        mtrc[:name], :description => mtrc[:description], :event_id =>
        mtrc[:event_id], :user_id => session[:user_id]
      metric.rank = mtrc[:rank]
      metric.value = mtrc[:value]
      if metric.save
        @message = 'Success'
      else
        @message = 'Metics could not be saved.'
      end
    end
    render :json => @message
  end
end
