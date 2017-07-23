require 'spec_helper'

describe MetricType do
  fixtures :events

  before(:each) do
    @event = Event.all[0]
  end

  it "creates a new metric type" do
    new_metric_type_name = 'New Metric Type'
    new_metric_type_description = 'This is New Metric Type.'
    new_metric_type_event_id = @event.id
    new_metric_type = MetricType.new :name =>
      new_metric_type_name, :description =>
      new_metric_type_description, :event_id => new_metric_type_event_id
    new_metric_type.save
    wanted_metric_type = nil
    MetricType.all.each do |metric_type|
      if metric_type.name == new_metric_type_name &&
          metric_type.event_id == new_metric_type_event_id
        wanted_metric_type = metric_type
      end
    end
    expect(wanted_metric_type.name).to eq(new_metric_type_name)
  end
end
