class DriveLog < ActiveRecord::Base

  def update_location
    self.location ||= Point.new
    self.location.x = latitude
    self.location.y = longitude
    self.save!
  end

end