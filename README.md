# Safecast API / Webapp #

This is the Safecast API app, implemented using Ruby / Ruby on Rails.

## Getting up and running ##

Jeremy ([@copiousfreetime](https://twitter.com/copiousfreetime)) recommended using PostGIS from the outset to ensure
that our database is location aware.

Here's the steps needed to get it going on OSX with homebrew:

    brew install postgis

We're using postgresql, you'll need to install that locally.

    brew install postgres

Then create a local superuser:

    createuser -s safecast

### Bootstrapping the database ###

Rails's builtin command will do this:

    rake db:create

Then bootstrap the schema:

    rake db:schema:load

Then the test database:

    rake db:test:prepare

Lastly, bootstrap the db to create an admin user:

    rake db:bootstrap

# Ruby Version #

Ruby 1.9.3 is the latest Ruby version, and includes performance fixes
for require, thereby decreasing loading time significantly.

### RVM ###

The app includes a `.rvmrc` file, which defines the Ruby version and
a gemset. Keeping things in a gemset allows safely running of gem
binaries without version conflicts.

For more information about getting up and running with rvm, please
visit: <https://rvm.io/>

# Tests #

All tests for this app use `rspec`, specifically rspec 2. The app
has been configured to use `spork` for pre-loading the Rails environment
and running tests in a forked process. The process for running the tests is:

    spork
    rspec spec

If you are offline, you can set the environment variable `CONNECTION_STATUS`
to `offline`, eg:

    CONNECTION_STATUS=offline spork

You can also run an individual test this way:

    rspec spec/integration/api/users_spec.rb

# References #

Rails + PostGIS
 http://lassebunk.dk/2011/09/10/creating-a-location-aware-website-using-ruby-on-rails-and-postgis/

# API Docs #

The API docs are written in markdown and live in the
/app/views/api/docs/markdown directory.  How-to's live in the root
markdown directory, while each resource's documentation lives in the
markdown/resources directory.

If you update a resource or change the behavior of the API, please make
sure to update the corresponding documentation.

# Cron #

The measurements table is output nightly to CSV, see script/dump_measurements ... this needs to be kept in sync with the queryable CSV export via the API endpoint at /api/measurements.csv