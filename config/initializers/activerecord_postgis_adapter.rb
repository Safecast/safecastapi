RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  config.default = RGeo::Geos.factory_generator

  config.register(RGeo::Geographic.spherical_factory(srid: 4326), geo_type: 'point')
end
