[Date, DateTime, Time, ActiveSupport::TimeWithZone].each do |klass|
  klass.class_eval do
    def as_json(*)
      xmlschema(0)
    end
  end
end
