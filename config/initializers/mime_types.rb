# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register 'application/vnd.safecast+json;version=1.0', :safecast_api_v1_json
Mime::Type.register 'application/vnd.safecast+xml;version=1.0', :safecast_api_v1_xml
Mime::Type.register 'application/vnd.google-earth.kml+xml', :kml
