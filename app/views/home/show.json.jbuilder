json.name 'Safecast API'
json.uri root_url
json.subresource_uris [
  users_path(:locale => false, :format => :json),
  measurements_path(:locale => false, :format => :json),
  bgeigie_imports_path(:locale => false, :format => :json),
  devices_path(:locale => false, :format => :json)
]