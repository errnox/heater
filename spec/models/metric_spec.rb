require 'spec_helper'

describe Metric do
  fixtures :events

  before(:each) do
    @event = Event.all[0]
  end

  it "creates a new metric" do
    new_metric_name = 'New Metric'
    new_metric_description = 'This is New Metric.'
    new_metric_rank = 1
    new_metric_value = 2
    new_metric_event_id = @event.id
    new_metric = Metric.new :name => new_metric_name, :description =>
      new_metric_description, :rank => new_metric_rank, :value =>
      new_metric_value, :event_id => new_metric_event_id
    new_metric.save
    wanted_metric = nil
    Metric.all.each do |metric|
      if metric.name == new_metric_name &&
          metric.event_id == @event.id
        wanted_metric = metric
      end
    end
    expect(wanted_metric.name).to eq(new_metric_name)
  end
end
