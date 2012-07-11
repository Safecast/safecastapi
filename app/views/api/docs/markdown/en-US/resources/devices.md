# Devices #

## Overview ##

The Safecast Device resource is under development.  It currently only supports three fields:

 * manufacturer
 * model
 * sensor

Devices can be created by POSTing to ```/api/devices``` with all of these fields.

If a device you are creating already exists in the database, the existing device will be returned and a duplicate will not be created.

It is likely that we will add a ```serial_number``` field and a ```measurement_type``` field in the future in order to single out specific devices and to separate devices that measure radiation from devices that measure air quality.


## GET ##

Retrieves an array of devices that match the supplied parameters.  If no parameters are supplied, the server returns the first 

### params ###

**manufacturer** Optional
The manufacturer of the device.

**model** Optional
The model number of the device, according to the manufacturer.

**sensor** Optional
The model of the sensing element used in the device.


## POST ##

Create a new device with the supplied parameters.

**device[manufacturer]** Required
The manufacturer of the device.

**device[model]** Required
The model number of the device, according to the manufacturer.

**device[sensor]** Required
The model of the sensing element used in the device.


NOTE: If the device already exists, you will still get an HTTP 201: Created response.

