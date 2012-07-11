# Measurements #

## Overview ##

Measurements are the core resource in Safecast's API.  They are geo-specific, which is to say, a measurement resource cannot be created without, at a minimum, a latitude and a longitude.

Measurements behave a bit differently than typical RESTful resources in that they cannot actually be updated or deleted.  A PUT request issued to update a measurement will actually create a new resource that is linked to the old resource by the `original_id` field.  The original resource's `expired_at` and `replaced_by` fields are also updated during this process so that a revision history of each measurement persists through changes.

## GET ##

Retrieve an array of measurements, filtered by the parameters provided.

### params ###
**latitude** Optional
**longitude** Optional
**distance** Optional
If all three of these parameters are included, the returned set of measurements will be limited to those that fall within `distance` meters of the coordinate (`latitude`, `longitude`).

**map_id** Optional
Limit the returned set to measurements that have been added to the map specified by the id.

**user_id** Optional
Limit the returned set to measurements that have been added by the user specified by the id.

**page_size** Optional, Defaults to 30
Maximum number of measurements returned in a single request.

**page** Optional, Defaults to 1
Pages are used to segment large sets of measurements.  Specifying a page indicates that the set of measurements returned should be offset by the page number multiplied by the page size.  


### Example ###

[GET Devices manufactured by Safecast](http://hurl.it/hurls/607c9f817a73baaf5ee3f8e68edb3376b37e2f01/26795a953f536610ea5010f0a6651d186c5dbf41)



## POST ##

Create a new measurement.

**map_id** Optional
Add the measurement to the map specified automatically after the measurement is created.

**measurement[latitude]**
The latitude of the measurement.  The latitude must be between -90.0 and 90.0.

**measurement[longitude]**
The longitude of the measurement.  The longitude must be between -180.0 and 180.0.

NOTE: Latitude and longitude are currently programmed to default to 0.0 if they are not provided by the caller.  This behavior should not be relied upon under any circumstances.

**measurement[value]**
The numeric value to associate with the measurement.

**measurement[unit]**
The unit of measurement's value.  For radiation, this is usually either 'cpm' or 'uSv/h'

**measurement[location_name]** Optional
A text description of the measurement's location.

**measurement[device_id]** Optional
The id of the device used to take the measurement.

**measurement[captured_at]** Optional
The timestamp of when the measurement was physically taken, which may be different than when the measurement resource was created in the database.







### Example ###
[POST the Safecast iGeigie device](http://hurl.it/hurls/9ac2ef3d267943e5c1e239aa38f0ed8fecf063a1/147994088b8114bd46cc0404a04da78a3afd9b71)


NOTE: If the device already exists, you will still get an HTTP 201: Created response.

