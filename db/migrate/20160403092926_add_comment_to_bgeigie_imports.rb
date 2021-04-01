class AddCommentToBgeigieImports < ActiveRecord::Migration
  def change
    add_column :measurement_imports, :comment, :string
  end
end
