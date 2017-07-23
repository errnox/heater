class CreateEventTypes < ActiveRecord::Migration
  def change
    create_table :event_types do |t|
      t.string :name
      t.string :description
      t.integer :event_id

      t.timestamps
    end
  end
end
