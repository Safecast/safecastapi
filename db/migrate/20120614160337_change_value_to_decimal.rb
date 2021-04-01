class ChangeValueToDecimal < ActiveRecord::Migration
  def up
    change_column :measurements, :value, :float
  end

  def down
    change_column :measurements, :value, :integer
  end
end
