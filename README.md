# Safecast API / Webapp #

This is the Safecast API app, implemented using Ruby / Ruby on Rails.

## Getting up and running ##

We're using postgresql, you'll need to install that locally.

There are a bunch of notes in safecast_installation_notes.txt

Then:

    createuser -s safecast

To create a local superuser...


# Ruby Version #

Ruby 1.9.3

### PostGIS ###

Jeremy (@copiousfreetime) recommended using PostGIS from the outset to ensure
that our database is location aware.

Here's the steps needed to get it going on OSX with homebrew:

    brew install postgis

### Bootstrapping the database ###

Rails's builtin command will do this:

    rake db:create

Then bootstrap the schema:

    rake db:schema:load
    
And finally the test database:

    rake db:test:prepare

# Delayed Job #

Uploads are processed async using Delayed job. You can kick it off with:

    rake jobs:work

or

    bundle exec rake jobs:work

# Tests #

All tests for this app use `rspec`, specifically rspec 2.

    rspec spec

You can also run an individual test this way:

    rspec spec/integration/api/users_spec.rb

# References #

Rails + PostGIS
  Daniel Azuma has a definitive series of posts using Rails with RGeo:

  http://blog.daniel-azuma.com/archives/category/tech/georails

# Cron #

The measurements table is output nightly to CSV, see script/dump_measurements ... this needs to be kept in sync with the queryable CSV export via the API endpoint at /api/measurements.csv