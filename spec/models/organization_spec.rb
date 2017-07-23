require 'spec_helper'

describe Organization do
  fixtures :organizations

  it "creates a new organization" do
    new_organization_name = 'NewCorp'
    new_organization_description = 'This is NewCorp.'
    new_organization =
      Organization.create(:name => new_organization_name,
                          :description => new_organization_description)
    new_organization.save
    wanted_organization = Organization.find_by_name(new_organization_name)
    expect(wanted_organization.name).to eq(new_organization_name)
  end

  it "finds an organization by name" do
    organization_name = 'BigCorp'
    organization = Organization.find_by_name organization_name
    expect(organization.name).to eq(organization_name)
  end

  it "finds an organization by description" do
    organization_description = 'This is BigCorp.'
    organization =
      Organization.find_by_description organization_description
    expect(organization.description).to eq(organization_description)
  end
end
