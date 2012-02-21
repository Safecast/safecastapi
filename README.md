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

### PostGIS ###

Jeremy (copiousfreetime) recommended using PostGIS from the outset to ensure
that our database is location aware.

Here's the steps needed to get it going on OSX with homebrew:

    brew install postgis
    createdb safecast_development
    createdb safecast_test
    cd /usr/local/share/postgresql/contrib/postgis-1.5 && \
    psql -d safecast_development -f postgis.sql -h localhost && \
    psql -d safecast_development -f spatial_ref_sys.sql -h localhost && \
    psql -d safecast_test -f postgis.sql -h localhost && \
    psql -d safecast_test -f spatial_ref_sys.sql -h localhost && cd -

That installs the PostGIS functions into the development and test databases.

### Bootstrapping the database ###

Rails's builtin command will do this:

    rake db:create

Then bootstrap the schema:

    rake db:schema:load
    
And finally the test database:

    rake db:test:prepare

### db:test:prepare ###

If you've been following along at home, everything probably went fine until that last line.

The problem is that db:test:prepare wipes out everything from PostGIS in the safecast_test database.

Katrina Owen proposed [a solution](http://www.katrinaowen.com/2011/01/13/postgresql-template-tables-and-rake-db-test-prepare) to create a template in psql and then use that template in the db config.  The db config part is already committed, but you still need to create the template on your local db.

    psql -d postgres
    CREATE DATABASE template_postgis WITH TEMPLATE=template1 ENCODING='UTF8';
    \c template_postgis;
    CREATE LANGUAGE plpgsql;
    \i /usr/local/share/postgresql/contrib/postgis-1.5/postgis.sql
    \i /usr/local/share/postgresql/contrib/postgis-1.5/spatial_ref_sys.sql
    UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
    GRANT ALL ON geometry_columns TO PUBLIC;
    GRANT ALL ON spatial_ref_sys TO PUBLIC;

So far, this seems to work.

# Tests #

All tests for this app use `rspec`, specifically rspec 2. The app has been configured to use `spork` for pre-loading the Rails environment and running tests in a forked process. The process for running the tests is:

    spork
    rspec spec

If you are offline, you can set the environment variable `CONNECTION_STATUS` to `offline`, eg:
    
    CONNECTION_STATUS=offline spork

You can also run an individual test this way:

    rspec spec/integration/api/users_spec.rb

# References #

Backbone Validations
https://github.com/n-time/backbone.validations
Rails + PostGIS
 http://lassebunk.dk/2011/09/10/creating-a-location-aware-website-using-ruby-on-rails-and-postgis/