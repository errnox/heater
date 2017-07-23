class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.string :description
      t.string :annotation
      t.integer :team_id

      t.timestamps
    end
  end
end
