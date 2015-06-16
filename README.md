# Safecast/safecastapi

The app that powers [api.safecast.org](https://api.safecast.org/)

## Overview

This is a rails app deployed in front of Postgres with Postgis. Data files generatated from various devices such as the [bGeigie Nano](http://nano.safecast.org) and are uploaded to the production app at api.safecast.org.

From there applications query the app's endpoints to pull the stored data for other purposes.

See the [Tilemap](https://github.com/Safecast/Tilemap/) Project's README for more diagrams on the complete data flow.

There is also a development host located at [dev.safecast.org](https://dev.safecast.org) which is used for testing features before rolling them to the main endpoint.

## Contributing

### Translation

Translation is managed by [Locale](http://www.localeapp.com/) and open to all.

You can edit translations on the [Safecast/safecastapi](http://www.localeapp.com/projects/public?search=Safecast/safecastapi) project on Locale.

The maintainers will then pull translations from the Locale project and push to Github.

Happy translating!

### Development

See one of the wiki pages for instructions on setting up for local development:

* [OS X and homebrew](https://github.com/Safecast/safecastapi/wiki/Development-Setup-on-OS-X)

### Licensing

Licensing can be confusing. We’ll try to make it a little less so.

Design, hardware, software, design and website content is shared by Safecast under the licenses specified below.

When you contribute to Safecast by participating in an event, submitting content or information to the webpage, submitting a pull request, testing or bug reporting, or sending data from your Safecast device then you license all of your contribution to Safecast and to all the world under these same licenses. Safecast will be attributed as the source.

All Data is Creative Commons Zero, anyone is free to make any use of the data, attribution is not legally required but is encouraged;
All Design is Creative Commons Attribution Share-Alike, anyone is free to copy, edit and republish the design but must make it clear Safecast is the source and the design must be published under the same or a compatible license;
All functional aspects of design are under the Berkeley Software Distribution License in respect of copyright and the XL1.0 Cross License in respect of patent;
Web Content is under Creative Commons Attribution Non Commercial, anyone can copy and remix the what is on the website but must attribute Safecast and anyone else specified by Safecast.
“Safecast” and the safecast logo are Registered Trademarks of the Momoko Ito Foundation, a 501(c)3 Non-profit, you can't use them without permission.
