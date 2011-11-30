# Safecast API / Webapp #

This is the Safecast API app, implemented using Ruby / Ruby on Rails.

## Getting up and running ##

We're using postgresql, you'll need to install that locally.

Then:
    createuser safecast

To create a local user... making sure to agree to making the user a superuser.


# Ruby Version #

Ruby 1.9.3 is the latest Ruby version, and includes performance fixes for require, thereby decreasing loading time significantly.

### RVM ###

The app includes a `.rvmrc` file, which defines the Ruby version and a gemset. Keeping things in a gemset allows safely running of gem binaries without version conflicts.

### Bootstrapping the database ###

Rails's builtin command will do this:

    rake db:create

Then bootstrap the schema:

    rake db:schema:load
    
And finally the test database:

    rake db:test:prepare

### PostGIS ###

Jeremy (copiousfreetime) recommended using PostGIS from the outset to ensure
that our database is location aware.

Here's the steps needed to get it going on OSX with homebrew:

    brew install postgis
    cd /usr/local/share/postgresql/contrib/postgis-1.5 && \
    psql -d safecast_development -f postgis.sql -h localhost && \
    psql -d safecast_development -f spatial_ref_sys.sql -h localhost && \
    psql -d safecast_test -f postgis.sql -h localhost && \
    psql -d safecast_test -f spatial_ref_sys.sql -h localhost && cd -

That installs the PostGIS functions into the development and test databases.

# Tests #

All tests for this app use `rspec`, specifically rspec 2. The app has been configured to use `spork` for pre-loading the Rails environment and running tests in a forked process. The process for running the tests is:

    spork
    rspec spec

You can also run an individual test this way:

    rspec spec/integration/api/users_spec.rb

# References #

Backbone Validations
https://github.com/n-time/backbone.validations
Rails + PostGIS
 http://lassebunk.dk/2011/09/10/creating-a-location-aware-website-using-ruby-on-rails-and-postgis/