require 'spec_helper'

describe "authentication routes" do
  it "routes GET /signup to sessions#new" do
    expect(:get =>  '/signup').to route_to(:controller => 'user',
                                           :action => 'new')
  end

  it "routes POST /signup to sessions#create" do
    expect(:post =>  '/signup').to route_to(:controller => 'user',
                                            :action => 'create')
  end

  it "routes GET /login to sessions#login" do
    expect(:get =>  '/login').to route_to(:controller => 'sessions',
                                          :action => 'login')
  end

  it "routes POST /login to sessions#login" do
    expect(:post =>  '/login').to route_to(:controller => 'sessions',
                                           :action => 'login_attempt')
  end

  it "routes GET /logout to sessions#logout" do
    expect(:get =>  '/logout').to route_to(:controller => 'sessions',
                                           :action => 'logout')
  end

  it "routes GET /home to sessions#home" do
    expect(:get =>  '/home').to route_to(:controller => 'sessions',
                                         :action => 'home')
  end

  it "routes GET /profile to sessions#profile" do
    expect(:get =>  '/profile').to route_to(:controller => 'sessions',
                                            :action => 'profile')
  end

  it "routes POST /profile to sessions#profile" do
    expect(:post =>  '/profile').to route_to(:controller => 'sessions',
                                             :action => 'change_email')
  end

  it "routes GET /settings to sessions#settings" do
    expect(:get =>  '/settings').to route_to(:controller => 'sessions',
                                             :action => 'settings')
  end

  it "routes POST /settings to sessions#settings" do
    expect(:post =>  '/settings').to route_to(:controller => 'sessions',
                                              :action => 'change_password')
  end
end
