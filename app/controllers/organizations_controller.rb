class OrganizationsController < ApplicationController
  before_filter :authenticate_user, :only => [:create, :index]
  before_filter :save_login_state, :only => [:login, :login_attempt]

  def create
    organization = Organization.new :name =>
      params[:name], :description => params[:description]
    if organization.save
      redirect_to :controller => 'organizations', :action => 'index',
      :organization_name => deurlify(organization.name)
    else
      flash[:notice] = 'Organization could not be created'
      redirect_to :controller => 'organizations', :action => 'create'
    end
  end

  def index
    @organization =
      Organization.find_by_name deurlify(params[:organization_name])
    @teams = []
    Team.all.each do |team|
      if team.organization_id == @organization.id
        @teams << team
      end
    end
    respond_to do |format|
      format.html
    end
  end
end
