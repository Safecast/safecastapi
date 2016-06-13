class AlterMeasurementImportsSubtypeSetNotNull < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE measurement_imports SET subtype = 'None' WHERE subtype IS NULL;
      ALTER TABLE measurement_imports ALTER COLUMN subtype SET NOT NULL;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE measurement_imports ALTER COLUMN subtype DROP NOT NULL;
    SQL
  end
end
