## API Documentation ##

The Safecast API provides programmatic access to the Safecast measurement database.  Users can use the API to add measurements to the database, or to query the existing data set.


# Getting Started #

In order to use the Safecast API, you must register for an account at https://api.safecast.org/.

Once you've created an account, you should retrieve your API Key from your profile.  **Every call you make to the Safecast API must include your API Key as a parameter**

For example:
``` curl https://api.safecast.org/api/measurements -v -H 'Accept: application/json' -d 'api_key=[your API key]' ```

