class AddComputedLocationToBgeigieLogs < ActiveRecord::Migration
  def change
    add_column :bgeigie_logs, :computed_location, :st_point, geographic: true
  end
end
