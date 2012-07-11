# API Documentation #

The Safecast API provides programmatic access to the Safecast measurement database.  Users can use the API to add measurements to the database, or to query the existing data set.


## Getting Started ##

In order to use the Safecast API, you must register for an account at https://api.safecast.org/.

Once you've created an account, you should retrieve your API Key from your profile.
**Every call you make to the Safecast API must include your API Key as a parameter**

For example:
``` curl https://api.safecast.org/api/measurements -v -X GET -H 'Accept: application/json' -d 'api_key=[your API key]' ```


## Resources ##

Safecast currently supports the following resources: (click on the links for details)

 * [Devices](resources/devices)
 * [Measurements](resources/measurements)
 * [Maps](resources/maps)
 * [bGeigie Imports](resources/bgeigie_imports)


## How-to ##

 * [Program a device to submit measurements](how_to_link_a_device_to_safecast)
 * [Retrieve the most recent measurements for a particular area](how_to_monitor_a_location)
