# Safecast/safecastapi
[![Build Status](https://travis-ci.org/Safecast/safecastapi.svg?branch=master)](https://travis-ci.org/Safecast/safecastapi) [![Circle CI](https://circleci.com/gh/Safecast/safecastapi.svg?style=svg)](https://circleci.com/gh/Safecast/safecastapi) [![Code Climate](https://codeclimate.com/github/Safecast/safecastapi/badges/gpa.svg)](https://codeclimate.com/github/Safecast/safecastapi) [![Test Coverage](https://codeclimate.com/github/Safecast/safecastapi/badges/coverage.svg)](https://codeclimate.com/github/Safecast/safecastapi/coverage)

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
