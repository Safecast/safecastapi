class AddIndexOnLocation < ActiveRecord::Migration
  def change
    add_index :measurements, :location, using: :gist
  end
end
