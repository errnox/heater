require 'spec_helper'

describe Event do
  fixtures :teams
  fixtures :events

  before(:each) do
    @team = Team.all[0]
  end

  it "creates a new event" do
    new_event_name = 'New Event'
    new_event_description = 'This is New Event.'
    new_event_annotation = 'No annotation'
    new_event_team_id = @team.id
    new_event = Event.new :name => new_event_name, :description =>
      new_event_description, :annotation =>
      new_event_annotation, :team_id => new_event_team_id
    new_event.save
    wanted_event = nil
    Event.all.each do |event|
      if event.name == new_event_name &&
          event.team_id == @team.id
        wanted_event = event
      end
    end
    expect(wanted_event.name).to eq(new_event_name)
  end
end
