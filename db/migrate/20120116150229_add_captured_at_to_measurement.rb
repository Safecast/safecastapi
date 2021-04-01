class AddCapturedAtToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :captured_at, :datetime
  end
end
