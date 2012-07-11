# Devices #

## Overview ##

The Safecast Device resource is under development.  It currently only supports four fields:

 * manufacturer
 * model
 * sensor
 * serial_number

Devices can be created by POSTing to ```/api/devices```.

If a device you are creating already exists in the database, the existing device will be returned and a duplicate will not be created.

It is likely that we will add a ```measurement_type``` field in the future in order to separate devices that measure radiation from devices that measure air quality.


## GET ##

Retrieves an array of devices that match the supplied parameters.  If no parameters are supplied, the server returns the first 

### params ###

**manufacturer** Optional
The manufacturer of the device.

**model** Optional
The model number of the device, according to the manufacturer.

**sensor** Optional
The model of the sensing element used in the device.

**serial_number** Optional
The serial number of the device.  If this parameter is supplied, the result is a single JSON object rather than an array of objects.


## POST ##

Create a new device with the supplied parameters.

Conceptually, there are two classes of devices in the Safecast database: specific devices, and generic devices.  Specific device resources contain a unique manufacturer/serial number pair and refer to one single device in the real world, while generic devices do not contain a serial number and maintain a unique manufacturer/model pair to avoid data duplication

**device[manufacturer]** Required
The manufacturer of the device.

**device[model]** Required
The model number of the device, according to the manufacturer.

**device[sensor]** Required
The model of the sensing element used in the device.

**device[serial_number]** Optional
If this field is provided, it must be unique for the supplied manufacturer.  That is, one manufacturer cannot have two devices with the same serial number, but two different manufacturers may.  If the serial number is not provided, this field defaults to nil and the device created should be thought of as generic.


NOTE: If the device already exists, you will still get an HTTP 201: Created response.

