class AddCounterCacheToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :measurements_count, :integer
  end
end
