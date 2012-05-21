class AddSpatialIndexOnMeasurements < ActiveRecord::Migration
  def up
    remove_index "measurements", "location"
    add_index "measurements", "location", :spatial=>true
  end

  def down
    remove_index "measurements", "location", :spatial=>true
    add_index "measurements", "location"
  end
end
