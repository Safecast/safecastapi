{
  safecast_api_v1_json: 'application/vnd.safecast+json;version=1.0',
  safecast_api_v1_xml: 'application/vnd.safecast+xml;version=1.0',
  kml: 'application/vnd.google-earth.kml+xml'
}.each do |sym, str|
  Mime::Type.register(str, sym)
end
