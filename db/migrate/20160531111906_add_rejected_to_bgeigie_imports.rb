class AddRejectedToBgeigieImports < ActiveRecord::Migration
  def change
    add_column :measurement_imports, :rejected, :boolean, default: false
    add_column :measurement_imports, :rejected_by, :string
  end
end
