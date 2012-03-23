class DriveImport < MeasurementImport
  has_many :drive_logs
  def self.update_locations
    transaction do
      self.find_each do |drive_import|
        drive_import.drive_logs.find_each do |drive_log|
          drive_log.update_location
        end
      end
    end
  end
end