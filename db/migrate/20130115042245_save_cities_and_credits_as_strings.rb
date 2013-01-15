class SaveCitiesAndCreditsAsStrings < ActiveRecord::Migration
  def up
    MeasurementImport.find_each do |measurement_import|
      if measurement_import.cities.present?
        measurement_import.update_column(:cities, YAML.load(measurement_import.cities).join(', '))
      end
      if measurement_import.credits.present?
        measurement_import.update_column(:credits, YAML.load(measurement_import.credits).join(', '))
      end
    end
  end

  def down
  end
end
