class AddUserIdAndCreatedAtIndexToMeasurements < ActiveRecord::Migration
  def change
    add_index :measurements, [:user_id, :captured_at]
  end
end
