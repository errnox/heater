class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :name
      t.string :description
      t.integer :rank
      t.integer :value
      t.integer :event_id
      # t.interger :user_id
      # t.string :annotation

      t.timestamps
    end
  end
end
