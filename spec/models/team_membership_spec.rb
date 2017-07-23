require 'spec_helper'

describe TeamMembership do
  it "creates a new team membership" do
    new_team_id = Team.all[0]
    new_user_id = User.all[0]
    new_team_membership = TeamMembership.new :team_id =>
      new_team_id, :user_id => new_user_id
    new_team_membership.save
    wanted_team_membership_id = new_team_membership.id
    wanted_team_membership =
      TeamMembership.find_by_id wanted_team_membership_id
    expect(wanted_team_membership.id).to eq(wanted_team_membership_id)
  end
end
