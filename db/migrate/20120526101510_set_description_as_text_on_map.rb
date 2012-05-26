class SetDescriptionAsTextOnMap < ActiveRecord::Migration
  def up
    change_column :maps, :description, :text
  end

  def down
    change_column :maps, :description, :string
  end
end
