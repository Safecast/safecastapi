class BgeigieImport < MeasurementImport
  
  def process
    self.update_attribute(:status, 'done')
  end
end
