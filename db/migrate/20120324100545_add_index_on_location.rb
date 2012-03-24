class AddIndexOnLocation < ActiveRecord::Migration
  def change
    add_index :measurements, :location
  end
end
