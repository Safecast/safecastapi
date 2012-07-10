# Devices #

## Overview ##

The Safecast Device resource is under development.  It currently only supports three fields:

 * manufacturer
 * model
 * sensor

Devices can be created by POSTing to ```/api/devices``` with all of these fields.

If a device you are creating already exists in the database, the existing device will be returned and a duplicate will not be created.

It is likely that we will add a ```serial_number``` field and a ```measurement_type``` field in the future in order to single out specific devices and to separate devices that measure radiation from devices that measure air quality.


## Supported Methods ##

### GET ###

Retrieves an array of devices that match the supplied parameters.

#### PARAMS ####

**manufacturer** Optional
The manufacturer of the device.

**model** Optional
The model number of the device, according to the manufacturer.

**sensor** Optional
The model of the sensing element used in the device.


### POST ###

All of the parameters of the GET request are required to POST a new device.  They must be provided in object format (i.e. a device's manufacturer must be provided as `device[manufacturer]` rather than just `manufacturer`)



## cURL examples ##

### POSTing a new device ###

```
curl https://api.safecast.org/api/devices -v -H 'Accept: application/json' -X POST -d 'device[manufacturer]=Safecast' -d 'device[model]=bGeigie' -d 'device[sensor]=LND-712' -d 'api_key=[your API key]'
```

```
* About to connect() to api.safecast.org port 443 (#0)
*   Trying 50.112.106.155... connected
* Connected to api.safecast.org (50.112.106.155) port 443 (#0)
* SSLv3, TLS handshake, Client hello (1):
* SSLv3, TLS handshake, Server hello (2):
* SSLv3, TLS handshake, CERT (11):
* SSLv3, TLS handshake, Server finished (14):
* SSLv3, TLS handshake, Client key exchange (16):
* SSLv3, TLS change cipher, Client hello (1):
* SSLv3, TLS handshake, Finished (20):
* SSLv3, TLS change cipher, Client hello (1):
* SSLv3, TLS handshake, Finished (20):
* SSL connection using RC4-SHA
* Server certificate:
*    subject: OU=Domain Control Validated; OU=EssentialSSL; CN=api.safecast.org
*    start date: 2012-03-15 00:00:00 GMT
*    expire date: 2015-03-15 23:59:59 GMT
*    subjectAltName: api.safecast.org matched
*    issuer: C=GB; ST=Greater Manchester; L=Salford; O=COMODO CA Limited; CN=EssentialSSL CA
*    SSL certificate verify ok.
> POST /api/devices HTTP/1.1
> User-Agent: curl/7.21.4 (universal-apple-darwin11.0) libcurl/7.21.4 OpenSSL/0.9.8r zlib/1.2.5
> Host: api.safecast.org
> Accept: application/json
> Content-Length: 106
> Content-Type: application/x-www-form-urlencoded
> 
< HTTP/1.1 201 Created
< Content-Type: application/json; charset=utf-8
< Transfer-Encoding: chunked
< Connection: keep-alive
< Status: 201
< X-Powered-By: Phusion Passenger (mod_rails/mod_rack) 3.0.11
< Location: https://api.safecast.org/device.1?locale=en-US
< X-UA-Compatible: IE=Edge,chrome=1
< ETag: "[request-specific ETag]"
< Cache-Control: max-age=0, private, must-revalidate
< Set-Cookie: _safecast_session=[request-specific cookie]; path=/; HttpOnly
< X-Request-Id: [request-specific X-Request-ID]
< X-Runtime: [request-specific X-Runtime]
< Date: Tue, 10 Jul 2012 04:45:06 GMT
< X-Rack-Cache: invalidate, pass
< Server: nginx/1.0.10 + Phusion Passenger 3.0.11 (mod_rails/mod_rack)
< 
* Connection #0 to host api.safecast.org left intact
* Closing connection #0
* SSLv3, TLS alert, Client hello (1):
{"id":1,"manufacturer":"Safecast","model":"bGeigie","sensor":"LND-712"}%  
```

NOTE: If the device already exists, you will still get an HTTP 201: Created response.


### GETting all devices from a certain manufacturer ###

The following request retrieves all devices whose `manufacturer` field contains `Safecast`.

```
curl https://api.safecast.org/api/devices -v -H 'Accept: application/json' -X GET -d 'manufacturer=Safecast'
```

```
* About to connect() to api.safecast.org port 443 (#0)
*   Trying 50.112.106.155... connected
* Connected to api.safecast.org (50.112.106.155) port 443 (#0)
* SSLv3, TLS handshake, Client hello (1):
* SSLv3, TLS handshake, Server hello (2):
* SSLv3, TLS handshake, CERT (11):
* SSLv3, TLS handshake, Server finished (14):
* SSLv3, TLS handshake, Client key exchange (16):
* SSLv3, TLS change cipher, Client hello (1):
* SSLv3, TLS handshake, Finished (20):
* SSLv3, TLS change cipher, Client hello (1):
* SSLv3, TLS handshake, Finished (20):
* SSL connection using RC4-SHA
* Server certificate:
*    subject: OU=Domain Control Validated; OU=EssentialSSL; CN=api.safecast.org
*    start date: 2012-03-15 00:00:00 GMT
*    expire date: 2015-03-15 23:59:59 GMT
*    subjectAltName: api.safecast.org matched
*    issuer: C=GB; ST=Greater Manchester; L=Salford; O=COMODO CA Limited; CN=EssentialSSL CA
*    SSL certificate verify ok.
> GET /api/devices HTTP/1.1
> User-Agent: curl/7.21.4 (universal-apple-darwin11.0) libcurl/7.21.4 OpenSSL/0.9.8r zlib/1.2.5
> Host: api.safecast.org
> Accept: application/json
> Content-Length: 21
> Content-Type: application/x-www-form-urlencoded
> 
< HTTP/1.1 200 OK
< Content-Type: application/json; charset=utf-8
< Transfer-Encoding: chunked
< Connection: keep-alive
< Status: 200
< X-Powered-By: Phusion Passenger (mod_rails/mod_rack) 3.0.11
< X-UA-Compatible: IE=Edge,chrome=1
< ETag: "[request-specific ETag]"
< Cache-Control: max-age=0, private, must-revalidate
< X-Request-Id: [request-specific X-Request-Id]
< X-Runtime: [request-specific X-Runtime]
< Date: Tue, 10 Jul 2012 04:49:56 GMT
< X-Rack-Cache: miss
< Server: nginx/1.0.10 + Phusion Passenger 3.0.11 (mod_rails/mod_rack)
< 
* Connection #0 to host api.safecast.org left intact
* Closing connection #0
* SSLv3, TLS alert, Client hello (1):
[{"id":1,"manufacturer":"Safecast","model":"bGeigie","sensor":"LND-712"}]
```


