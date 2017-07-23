class RenameEventTypesToMetricTypes < ActiveRecord::Migration
  def change
    rename_table :event_types, :metric_types
  end
end
