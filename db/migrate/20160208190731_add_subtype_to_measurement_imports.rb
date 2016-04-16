class AddSubtypeToMeasurementImports < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE measurement_imports_subtype AS ENUM ('None', 'Drive', 'Surface', 'Cosmic');
      ALTER TABLE measurement_imports
        ADD COLUMN subtype measurement_imports_subtype
        NOT NULL
        DEFAULT 'None';
    SQL
    add_index :measurement_imports, :subtype
    add_index :measurement_imports, [ :id, :subtype ]
  end

  def down
    execute <<-SQL
      ALTER TABLE measurement_imports
        DROP COLUMN subtype;
      DROP TYPE measurement_imports_subtype;
    SQL
  end
end
