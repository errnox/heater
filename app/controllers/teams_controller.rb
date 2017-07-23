class TeamsController < ApplicationController
  before_filter :authenticate_user, :only => [:create, :index]
  before_filter :save_login_state, :only => [:login, :login_attempt]

  @@events_page_size = 10
  @@events_search_result_limit = 60

  def create
    team = Team.new :name => params[:name], :description =>
      params[:description], :organization_id => params[:organization_id]
    organization = Organization.find_by_id params[:organization_id]
    if team.save
      redirect_to :controller => 'teams', :action =>
        'index', :organization_name =>
        organization.name, :team_name => team.name
    else
      flash[:notice] = 'Team could not be created'
      redirect_to :controller => 'teams', :action => 'create'
    end
  end

  def index
    @currentUser = User.find_by_id session[:user_id]
    @team = nil
    @events = []
    @organization =
      Organization.find_by_name(deurlify(params[:organization_name]))
    organization_id = @organization.id
    Team.all.each do |team|
      if team.organization_id == organization_id &&
          team.name == deurlify(params[:team_name])
        @team = team
      end
    end
    if @team != nil && @organization != nil

      # Events
      Event.all.each do |event|
        if event.team_id == @team.id
          @events << event
        end
      end

      @events_num = @events.length
      @pages_total = (@events_num / @@events_page_size) + 1
      @events_search_result_limit = @@events_search_result_limit
      @events = @events.sort_by(&:created_at).reverse[0,@@events_page_size]

      @user_is_team_member = false
      team_id = Team.find_by_name(deurlify(params[:team_name])).id
      TeamMembership.all.each do |membership|
        if membership.user_id == session[:user_id] &&
            membership.team_id == team_id
          @user_is_team_member = true;
        end
      end
      @team_members = []
      TeamMembership.all.each do |membership|
        if membership.team_id == @team.id
          user = User.find_by_id membership.user_id
          @team_members << user
        end
      end
      respond_to do |format|
        format.html
      end
    end
  end

  def team_events_page
    @page = params[:page].to_i
    @team = Team.find_by_name deurlify(params[:team_name])
    @events = []
    Event.all.each do |event|
      if event.team_id == @team.id
        @events << event
      end
    end
    @pages_total = (@events.length / @@events_page_size) + 1

    offset = @@events_page_size * (@page - 1)
    @events = @events.sort_by(&:created_at)
      .reverse[offset..(offset + @@events_page_size - 1)]

    @data = {:page => @page, :pagesTotal => @pages_total, :events =>
      @events}
    render :json => @data
  end

  def search_events
    @events = []
    events = []
    @team = Team.find_by_name deurlify(params[:team_name])
    search_query = params[:q]

    Event.all.each do |event|
      if event.team_id == @team.id
        events << event
      end
    end

    events = events.sort_by(&:created_at).reverse
    events.each do |event|
      if event.name =~ /#{search_query}/ ||
          event.description =~ /#{search_query}/
        @events <<  event
      end
    end

    @events = @events[0...@@events_search_result_limit]

    render :json => @events
  end
end
