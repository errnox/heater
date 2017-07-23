class AddUserIdAndAnnotationToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :user_id, :integer
    add_column :metrics, :annotation, :string
  end
end
