require 'spec_helper'

describe "authentication routes" do
  it "routes GET /profile/red to sessions#profile" do
    expect(:get =>  '/profile/red').to route_to(:controller => 'user',
                                                :action => 'profile',
                                                :name => 'red')
  end
end
