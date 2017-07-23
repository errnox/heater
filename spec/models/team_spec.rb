require 'spec_helper'

describe Team do
  it "creates a new team" do
    organization = Organization.all[0]
    new_team_name = 'Test Team'
    new_team_description = 'This is Test Team.'
    new_team_organization_id = @organizationid
    new_team = Team.new :name => new_team_name, :description =>
      new_team_description, :organization_id => new_team_organization_id
    new_team.save
    wanted_team = nil
    Team.all.each do |team|
      if team.name == new_team_name &&
          team.organization_id == new_team_organization_id
        wanted_team = team
      end
    end
    expect(wanted_team.name).to eq(new_team_name)
    expect(wanted_team.organization_id).to eq(new_team_organization_id)
  end
end
