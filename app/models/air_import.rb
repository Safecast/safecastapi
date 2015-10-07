class AirImport < MeasurementImport
  belongs_to :user

  def finalize!
    self.status = 'done'
    self.measurements_count = 5
    save
  end
end