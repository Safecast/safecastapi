# Measurements #

## Overview ##

Measurements are the core resource in Safecast's API.  They are geo-specific, which is to say, a measurement resource cannot be created without, at a minimum, a latitude and a longitude.

Measurements behave a bit differently than typical RESTful resources in that they cannot actually be updated or deleted.  A PUT request issued to update a measurement will actually create a new resource that is linked to the old resource by the `original_id` field.  The original resource's `expired_at` and `replaced_by` fields are also updated during this process so that a revision history of each measurement persists through changes.

## GET ##

Retrieve an array of measurements filtered by the parameters provided.

### params ###


### Example ###

[GET Devices manufactured by Safecast](http://hurl.it/hurls/607c9f817a73baaf5ee3f8e68edb3376b37e2f01/26795a953f536610ea5010f0a6651d186c5dbf41)



## POST ##

### Example ###
[POST the Safecast iGeigie device](http://hurl.it/hurls/9ac2ef3d267943e5c1e239aa38f0ed8fecf063a1/147994088b8114bd46cc0404a04da78a3afd9b71)

