class DriveLog < ActiveRecord::Base

  def update_md5sum
    
  end

  def update_location
    self.location ||= Point.new
    self.location.y = latitude
    self.location.x = longitude
    self.save!
  end

end