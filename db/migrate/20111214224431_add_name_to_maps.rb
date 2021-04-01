class AddNameToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :name, :string
  end
end
