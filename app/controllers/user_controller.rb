class UserController < ApplicationController
  before_filter :authenticate_user, :only => [:profile]
  before_filter :save_login_state, :only => [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]

    if !(User.find_by_name @user.name)
      if @user.save
        flash[:notice] = "You signed up successfully."
      else
        flash[:notice] = "Signup form is invalid."
      end
      authorized_user = User.authenticate(params[:user][:name],
                                          params[:user][:password])
      if authorized_user
        session[:user_id] = authorized_user.id
        flash[:notice] = "Welcome! You have successfully authenticated."
        redirect_to :controller => 'sessions', :action => 'home'
      else
        flash[:notice] = 'Invalid credentials'
        redirect_to :controller => 'sessions', :action => 'login'
      end
    else
      flash[:notice] = 'Username not available.'
      redirect_to :controller => 'user', :action => 'create'
    end
  end

  def profile
    @user = nil
    User.all.each do |user|
      if user.name == params[:name]
        @user = user
      end
    end
    @teams = []
    TeamMembership.all.each do |membership|
      if membership.user_id == @user.id
        team = Team.find_by_id membership.team_id
        if team != nil
          organization = Organization.find_by_id team.organization_id
          @teams << [team, organization]
        end
      end
    end
    render 'profile'
  end
end
