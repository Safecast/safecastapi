module My::BgeigieImportsHelper
  def collect_bgeigie_logs(bgeigie_logs)
    bgeigie_logs.collect do |b|
      point = {
        :lat => b.latitude, 
        :lng => b.longitude,
        :cpm => b.cpm
      }
    end
  end
end