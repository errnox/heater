require 'digest/sha1'

class SessionsController < ApplicationController
  @@all_organizations_page_size = 5

  before_filter :authenticate_user, :only => [:home, :profile, :settings,
                                              :organizations,
                                              :all_organizations,
                                              :all_organizations_page]
  before_filter :save_login_state, :only => [:login, :login_attempt]

  def login
    respond_to do |format|
      format.html
    end
  end

  def login_attempt()
    authorized_user = User.authenticate(params[:name_or_email],
                                        params[:password])
    if authorized_user
      session[:user_id] = authorized_user.id
      flash[:notice] = "Welcome!"
      redirect_to :controller => 'sessions', :action => 'home'
    else
      flash[:notice] = 'Invalid credentials'
      redirect_to :controller => 'sessions', :action => 'login'
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to :action => 'login'
  end

  def change_password
    current_user = User.find_by_name params[:name]
    if current_user &&
        current_user.password == Digest::SHA1.hexdigest("\
#{current_user.salt}#{params[:old_password]}")
      current_user.password = params[:new_password]
      current_user.save
      flash[:notice] = 'Your password has been changed successfully.'
      redirect_to :controller => 'sessions', :action => 'home'
    else
      flash[:notice] = 'You are not authorized.'
      redirect_to :controller => 'sessions', :action => 'settings'
    end
  end

  def change_email
    current_user = User.find session[:user_id]
    if current_user
      current_user.email = params[:new_email]
      User.skip_callback(:save, :before, :encrypt_password)
      if current_user.save
        User.set_callback(:save, :before, :encrypt_password)
        flash[:notice] =
          'Your email address has been changed successfully.'
        redirect_to :controller => 'sessions', :action => 'home'
      else
        User.set_callback(:save, :before, :encrypt_password)
        flash[:notice] =
          'Not a valid email address.'
        redirect_to :controller => 'sessions', :action => 'profile'
      end
    else
      flash[:notice] = 'Email address could not be changed.'
      redirect_to :controller => 'sessions', :action => 'profile'
    end
  end

  def home
    @teams = []
    teams = []
    @organizations = []
    TeamMembership.all.each do |membership|
      if membership.user_id == session[:user_id]
        team = Team.find_by_id membership.team_id
        if team != nil
          organization = Organization.find_by_id team.organization_id
          teams << team
          @teams << [team, organization]
          @organizations |= [organization]
        end
      end
    end

    # Unsubmitted Events

    # Teams
    # @team_memberships = TeamMembership.where :user_id =>
    #   session[:user_id]
    # @teams = []
    # @team_memberships.each do |team_membership|
    #   team = Team.find_by_id(team_membership.team_id)
    #   @teams << team if team != nil
    # end

    # Organizations
    # @organizations = []
    # @teams.each do |team|
    #   organization = Organization.find_by_id(team.organization_id)
    #   @organizations << organization
    # end

    # Nested hash: Organization names -> Team names -> Events
    @unsubmitted_events = []
    teams.each do |team|
      e  = Event.where :team_id => team.id
      metrics = []
      e.each do |event|
        metric = Metric.find_by(:user_id =>
                                session[:user_id], :event_id => event.id)
        metrics << metric if metric != nil
      end
      submitted_event_ids = metrics.map(&:event_id).uniq
      events = e.reject { |evt| submitted_event_ids.include?(evt.id) }
      events.each do |event|
        team = Team.find_by_id event.team_id
        organization = Organization.find_by_id team.organization_id
        @unsubmitted_events << [organization, team, event]
      end
    end
    @unsubmitted_events = @unsubmitted_events.sort_by do |e|
      e[2][:created_at]
    end.reverse
    @latest_unsubmitted_events = @unsubmitted_events[0,5]
    respond_to do |format|
      format.html
    end
  end

  def profile
    respond_to do |format|
      format.html
    end
  end

  def settings
    respond_to do |format|
      format.html
    end
  end

  def organizations
    @organizations = []
    TeamMembership.all.each do |membership|
      if membership.user_id == session[:user_id]
        team = Team.find_by_id membership.team_id
        if team != nil
          organization = Organization.find_by_id team.organization_id
          @organizations |= [organization]
        end
      end
    end
    respond_to do |format|
      format.html
    end
  end

  def all_organizations
    redirect_to(all_organizations_pagina_url(1))
  end

  def all_organizations_page
    @organizations = []
    @is_last_page = params[:is_last_page] || false
    page_num = params[:page].to_i

    @organizations_num = Organization.all.length
    @teams_num = Team.all.length

    Organization
      .limit(@@all_organizations_page_size)
      .offset(@@all_organizations_page_size * (page_num - 1))
      .each do |organization|
      teams = Team.where :organization_id => organization.id || []
      @organizations << [organization, teams]
    end

    # Redirect to the max page num page or render the template.
    unless !@organizations.empty? || page_num <= 0
      redirect_to(all_organizations_pagina_url(page_num - 1,
                                               :is_last_page => true))
    else
      # Hide the "previous"/"next" arrows if necessary.
      if (@@all_organizations_page_size * (page_num)) >=
          @organizations_num || @organizations.length >=
          @organizations_num
        @is_last_page = true
      end
      @page = page_num
      render :template => 'sessions/all_organizations'
    end

  end
end
