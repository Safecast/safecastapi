class IndexMeasurementsOnCapturedAt < ActiveRecord::Migration
  def change
    add_index :measurements, :captured_at
  end
end
