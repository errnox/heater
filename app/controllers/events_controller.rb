class EventsController < ApplicationController
  before_filter :authenticate_user, :only => [:new, :index, :unsubmitted]
  before_filter :save_login_state, :only => [:login, :login_attempt]

  def new
    @message = ''
    @data = {}
    error_message = 'Event could not be created.'
    event = Event.new :name => params[:name], :description =>
      params[:description], :team_id =>
      params[:team_id], :annotation => params[:annotation]
    team_membership = nil
    TeamMembership.all.each do |membership|
      if membership.user_id == session[:user_id] &&
          membership.team_id == params[:team_id]
        team_membership = membership
      end
    end
    if team_membership != nil
      if team_membership.user_id == session[:user_id]
        if event.save
          @message = 'Success'
          params[:metricTypes].each do |metric_type|
            new_metric_type = MetricType.new :name =>
              metric_type['name'], :description =>
              metric_type['description'], :event_id =>
              event.id
            unless new_metric_type.save
              @message = error_message
            end
          end
        else
          @message = error_message
        end
      else
        @message = 'Only team members can create events.'
      end
    else
      @message = 'Only team members can create events.'
    end

    # Events
    @events = [];
    Event.all.each do |evt|
      if evt.team_id == params[:team_id]
        @events << evt
      end
    end
    @newEvent = @events.sort_by(&:created_at).reverse[0]

    @data['message'] = @message
    @data['newEvent'] = @newEvent
    render :json => @data
  end

  def index
    @organization = Organization.find_by :name =>
      deurlify(params[:organization_name])
    @team = Team.find_by :name =>
      deurlify(params[:team_name]), :organization_id => @organization.id
    @user_is_team_member = TeamMembership.find_by :team_id =>
      @team.id, :user_id => session[:user_id]

    if @user_is_team_member
      @event = Event.find_by :id => deurlify(params[:event_id])
      @team_memberships = TeamMembership.where :team_id => @team.id
      @team_members = []
      @team_memberships.each do |team_membership|
        @team_members << User.find_by(:id => team_membership.user_id)
      end

      # Team members
      @already_submitted_users = []
      @not_yet_submitted_users = []
      @team_members.each { |m| @not_yet_submitted_users << m }
      Metric.where(:event_id =>  @event.id).each do |metric|
        user = User.find metric.user_id
        @already_submitted_users << user
        @not_yet_submitted_users.delete_if do |u|
          u.id == user.id
        end
      end
      @already_submitted_users = @already_submitted_users.uniq
      @not_yet_submitted_users = @not_yet_submitted_users.uniq

      # Metrics
      @metric_types = MetricType.where :event_id => @event.id
      @metric_ranks = {}
      @metric_types.each do |metric_type|
        @metric_ranks[metric_type.name] = {'rank' => 0, 'value' => 0}
      end
      @metrics = Metric.where :event_id => @event.id
      @metrics.each do |metric|
        @metric_ranks[metric.name]['rank'] += metric.rank
        @metric_ranks[metric.name]['value'] += metric.value
      end

      @no_submissions_yet = false
      if @metrics.length == 0
        @no_submissions_yet = true
      end

      if !@no_submissions_yet
        @metrics_ranked_by_value = {}
        v = []
        @metric_ranks.each { |key, value| v << value['value']}
        v = v.uniq.sort.reverse
        v.each do |value|
          @metric_ranks.each do |metric_name, values|
            metric_value = values['value']
            if metric_value == value
              if @metrics_ranked_by_value[metric_value.to_s] == nil
                @metrics_ranked_by_value[metric_value.to_s] = [metric_name]
              else
                @metrics_ranked_by_value[metric_value.to_s] << metric_name
              end
            end
          end
        end
        @metrics_ranked_by_value = @metrics_ranked_by_value.values

        @metrics_ranked_by_rank = {}
        r = []
        @metric_ranks.each { |key, value| r << value['rank']}
        r = r.uniq.sort.reverse
        r.each do |value|
          @metric_ranks.each do |metric_name, values|
            metric_rank = values['rank']
            if metric_rank == value
              if @metrics_ranked_by_rank[metric_rank.to_s] == nil
                @metrics_ranked_by_rank[metric_rank.to_s] = [metric_name]
              else
                @metrics_ranked_by_rank[metric_rank.to_s] << metric_name
              end
            end
          end
        end
        @metrics_ranked_by_rank = @metrics_ranked_by_rank.values

        # Check if the current user has already submitted metrics
        @user_has_submitted_metrics = false
        if Metric.find_by(:user_id =>
                          session[:user_id], :event_id => @event.id) != nil
          @user_has_submitted_metrics = true
        end

        # User metrics
        @user_metrics = {}
        @team_members.each do |team_member|
          m = Metric.where(:user_id => team_member.id, :event_id =>
                           @event.id).sort_by(&:rank)
          metrics = []
          m.each do |mtrc|
            metrics << mtrc
          end
          @user_metrics[team_member.name] = {}
          @user_metrics[team_member.name]['user'] = team_member
          @user_metrics[team_member.name]['metrics'] = metrics
          if m.length == 0
            @user_metrics[team_member.name]['did_submit'] = false
          else
            @user_metrics[team_member.name]['did_submit'] = true
          end
        end
      end
    else
      render 'redirects/team_members'
    end
  end

  def unsubmitted
    # Teams
    @team_memberships = TeamMembership.where :user_id =>
      session[:user_id]
    @teams = []
    @team_memberships.each do |team_membership|
      team = Team.find_by_id(team_membership.team_id)
      @teams << team if team != nil
    end

    # Organizations
    @organizations = []
    orgs = {}
    @teams.each do |team|
      organization = Organization.find_by_id(team.organization_id)
      @organizations << organization
      orgs[organization.id.to_s] = organization
    end

    # Events

    # Nested hash: Organization names -> Team names -> Events
    @unsubmitted_events = {}
    @teams.each do |team|
      org_name = orgs[team.organization_id.to_s].name
      if @unsubmitted_events[org_name] == nil
        @unsubmitted_events[org_name] = {}
      end
      @unsubmitted_events[org_name][team.name] = []
      e  = Event.where :team_id => team.id
      metrics = []
      e.each do |event|
        metric = Metric.find_by(:user_id =>
                                session[:user_id], :event_id => event.id)
        metrics << metric if metric != nil
      end
      submitted_event_ids = metrics.map(&:event_id).uniq
      events = e.reject { |evt| submitted_event_ids.include?(evt.id) }
      @unsubmitted_events[org_name][team.name] << events if !events.empty?
      # Delete empty team entries
      # (For users who frequently submit metrics this is faster than making
      # yet another DB query. For users who do not submit often the
      # "overhead" of adding elemnts to the hash that are then deleted
      # should not be overly noticable since they do not view the list of
      # unsubmitted events often anyway.)
      if @unsubmitted_events[org_name][team.name].empty?
        @unsubmitted_events[org_name].delete(team.name)
      end
      if @unsubmitted_events[org_name].empty?
        @unsubmitted_events.delete(org_name)
      end
    end
  end
end
