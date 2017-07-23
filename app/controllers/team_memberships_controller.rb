class TeamMembershipsController < ApplicationController
  before_filter :authenticate_user, :only => [:join, :leave, :teams,
                                              :teams_page]
  before_filter :save_login_state, :only => [:login, :login_attempt]

  @@teams_page_size = 50

  def join
    @message = 'Not possible'
    team_id = Team.find_by_name(deurlify(params[:team_name])).id
    team_membership = TeamMembership.new :user_id =>
      session[:user_id], :team_id => team_id
    if team_membership.save
      @message = 'Success'
    end
    render :json => @message
  end

  def leave
    @message = 'Not possible'
    team_membership = nil;
    team_id = Team.find_by_name(deurlify(params[:team_name])).id
    TeamMembership.all.each do |membership|
      if membership.user_id == session[:user_id] &&
          membership.team_id == team_id
        team_membership = membership;
      end
    end
    if team_membership != nil
      if team_membership.destroy
        @message = 'Success'
      end
    end
    render :json => @message
  end

  def teams
    redirect_to teams_pagina_url(:page => 1)
  end

  def teams_page
    @page = params[:page].to_i
    teams = []
    @is_last_page = params[:is_last_page] || false
    TeamMembership.all.each do |membership|
      if membership.user_id == session[:user_id]
        team = Team.find_by_id membership.team_id
        if team != nil
          teams << [team, Organization.find_by_id(team.organization_id)]
        end
      end
    end

    # Total number of teams
    @teams_num = teams.length

    # Pagination window
    offset = @@teams_page_size * (@page - 1)
    @teams = teams[offset..(offset + @@teams_page_size - 1)] || []


    # Do not show the "next" button if there are too few teams for
    # pagination.
    if @teams.length >= teams.length
      @is_last_page = true
    end

    unless !@teams.empty? || @page <= 0
      redirect_to(teams_pagina_url(@page - 1, :is_last_page => true))
    else
      render :controller => controller_name, :action => 'teams'
    end
  end
end
