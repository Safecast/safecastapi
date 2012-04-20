module My::BgeigieImportsHelper
  def collect_points(bgeigie_import)
    bgeigie_import.bgeigie_logs.collect do |b|
      point = {
        :lat => b.latitude, 
        :lng => b.longitude,
        :cpm => b.cpm
      }
    end
  end
end