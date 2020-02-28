## Deployment on AWS

### Pre-requisites

* A login for the `safecast` AWS account ([contact mat](mailto:mat@schaffer.me))
* The `safecastapi` private SSH key ([contact mat](mailto:mat@schaffer.me))

* AWS CLI & ElasticBeatnstalk CLI
  * Run `pip install -r requirements.txt` under a python virtualenv ([direnv](https://direnv.net/) makes virtualenvs easy)

* Terraform
  * [tfenv](https://github.com/tfutils/tfenv) is recommended as terraform versions will change over time

* A configured `safecast` AWS profile (`aws configure --profile safecast`)

### Creating new environments

To create a new environment pair (worker & web), you'll need DB connection info first. You can get this by creating a new RDS (ideally via terraform) or using the info from an existing environment. Once you've got that info, run the rake task to create the env.

```
AWS_EB_DATABASE_HOST=... \
AWS_EB_DATABASE_PASSWORD=... \
AWS_EB_CFG=(dev/prd/whatever) \
rake elasticbeanstalk:create
```

The environment name will be numeric based on existing environments of the same config name.

If you're working against an empty DB, you can run `db:structure:load` to load `structure.sql` to the new DB.

You will see a few errors regarding extensions and grants, but those can be ignored.

If you need to run any rails commands to debug anything you can do this:

```
rake ssh_dev          # or prd
cd /var/app/current   # or /var/app/ondeck for any failed deployment assets
bundle exec rails c   # or whatever command you need
```

### Database performance

As of May 2019, api.safecast.org is somewhat prone to problems due to database overloading.

This is due to it's large data set combined with a flexible query API. It's quite easy for users to generate queries which cause table scans of the `measurements` table.

These take several minutes and burn lots of I/O so if too many happen at once the DB can become overloaded. Since all UI requests rely on the DB, this overload will lead to 5xx errors when trying to load the site.

If you suspect trouble the [API Overview dashboard](https://grafana.safecast.cc/d/W7c552kZz/api-overview) can be a good place to start.

If the RDS CPU or I/O stats are quite high, it can be good to clear in-flight queries.

This will fail some requests in flight, but most everything can be retried and it should be easier to find out what's causing trouble once the query load is more under control.

First SSH into an EC2 instance (e.g.,  `rake ssh_prd_wrk`). Then run the `psql` command to get a DB console.

Then you can use this query to see what's in flight and for how long:

```
select pid, age(clock_timestamp(), query_start), query
from pg_stat_activity
where state != 'idle' and query not like '%pg_stat_activity%'
order by query_start desc; 
```

If you have many long running queries, you can terminate older queries using something like this to terminate any query that's been running longer than 5 minutes.

```
select pg_terminate_backend(pid)
from pg_stat_activity
where state != 'idle' and query_start < now() - interval '5 minutes';
```

Cron jobs are handled via elastic beanstalk's aws-sqsd which can also back up if the DB is slow for an extended period of time.

If this happens, the messages in flight will be high (more than 1 or 2). Clearing the SQS queue via [the AWS console](https://console.aws.amazon.com/sqs/home?region=us-west-2) can be a good idea to ensure we're not re-computing any jobs.

The production queue should be `awseb-e-aaw6am7e2x-stack-AWSEBWorkerQueue-3WZCP00RYHUX` which can be verified by the `Name` tag on the queue.

## Upgrading the database

The instructions below were tested on the ingest database; as of September 2019, they have not been tested on the api database.

This process is for major version upgrades, e.g. from Postgres 9.5 to 9.6 or from 10 to 11, but not from 11.4 to 11.5. Minor version upgrades, like from 11.4 to 11.5, are automatically scheduled and performed by AWS. Read about the [the PostgreSQL versioning model](https://www.postgresql.org/support/versioning/).

### Terraform

Terraform has been configured for ingest in a way that should make it easy to perform major upgrades. If Amazon automatically performs a minor version upgrade, this will not break Terraform. In `infrastructure/terraform/ingest/main.tf`, the `engine_version` variable is set to `11` rather than `11.4` to ensure this; Terraform is aware of automatic upgrades and the Postgres versioning scheme.

However, Terraform cannot upgrade PostGIS, and AWS recommends that PostGIS be upgraded before a major upgrade. See the manual instructions below for more information on how to upgrade it.

To upgrade to the next version, e.g., Postgres 12, find the following lines in the Terraform configuration and change them from `11` to `12`:

* `main.tf`
  - `resource "aws_db_instance" "prd-master" {`
    * `engine_version = "11"`
  - `resource "aws_db_parameter_group" "public-replica" {`
    * `family = "postgres11"`
* `dev.tf`
  - `resource "aws_db_instance" "dev-master" {`
    * `engine_version = "11"`

Read through the manual instructions as well to understand what Terraform should do when executing this plan.

### Manual

Try to use the Terraform upgrade process first. These instructions are captured here for reference in case using Terraform is not possible.

1. Read about [the PostgreSQL versioning model](https://www.postgresql.org/support/versioning/) and note the change in which digit of the version number denotes a major upgrade between Postgres 9 and Postgres 10.
1. Read [the AWS guide to upgrading Postgres](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html)
1. Read [the guide to upgrading PostGIS](https://postgis.net/docs/postgis_installation.html#upgrading) in order to understand the PostGIS concept of "hard" and "soft" upgrades.
1. Check which extensions are installed; usually at least PostGIS will be: `SELECT extname, extversion FROM pg_extension`
1. Determine the versions of PostGIS and other extensions to upgrade to. The tables that list which versions of extensions are available in which Postgres version are listed in [in this AWS document](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html).
1. Go to the RDS control panel, identify the read replica's configuration, and save all of it somewhere, e.g. copy/paste it to your desktop. It helps to click "Modify" and look at what is modifiable there.
1. Once you are ready to start the process, and have saved the read replica's configuration, delete the read replica of the database. Read replicas cannot survive a major upgrade. Deleting it before starting the upgrade saves the performance and financial cost of replicating the `VACUUM` command's writes to the read replica.
1. SSH to the `safecastingest-prd` instance (or whatever instance is correct for your application) as `ec2-user`; the current DNS value can be found in the AWS EC2 console.
1. Execute a `VACUUM`; optionally, time it: `time psql -c 'VACUUM;'` Doing so ahead of time will make the upgrade go faster.
1. Upgrade to the next major version of Postgres via the AWS RDS console, by clicking "Modify" on the appropriate database. Make sure to schedule the upgrade to happen immediately.
1. Once the database upgrade is complete, perform either a hard or soft upgrade of PostGIS as necessary. This can also be done with `psql` on the application server instance.
1. Repeat as necessary. Since PostGIS is installed, according to the AWS documentation, the upgrade must be done by iterating through each major version to the target version; you cannot skip ahead to the end. This is likely a safer course of action regardless, since each major upgrade may change the on-disk data storage format.
1. Create a new read replica with the exact same name as the old one. This will ensure it has the same DNS name as the old one, and the public DNS alias `ingest-replica1.prd.safecast.cc` will continue to work.
1. Compare the configuration of the old and new replicas until they match. Ensure that the replica and master are in the same availability zone to minimize any performance or financial costs.
1. Update [the Terraform configuration](https://github.com/Safecast/infrastructure) to reflect these changes. This repository is private; you may need to ask for access.

## Releasing a new version of ingest

Pushing a new application version is done from the AWS Elastic Beanstalk console.

* Upgrade the workers, e.g. the `dev-wrk` environment, **before** upgrading the corresponding server environment. This will automatically run `rails db:migrate`.
* In the Elastic Beanstalk console, click on the application name, then "Application versions." From here, select the version to deploy. Version labels are automatically generated by CircleCI; it should be possible to find the version corresponding to your last known good build number. It's possible to complete the deployment from the "Actions" tab.

## Upgrading ingest Elastic Beanstalk environments

There's two common cases when the Elastic Beanstalk environment for ingest needs to be replaced:

* When upgrading the version of Ruby in use
* When upgrading the version of Postgres server and client in use.

It's important that the major version of the Postgres client binaries on the application servers matches the version of the Postgres server; otherwise, deployment of the application will fail. Therefore, after upgrading the major version of the Postgres server (e.g. from 11 to 12), upgrade the application servers soon thereafter.

### Upgrading the Ruby version

Upgrade these ingest project files:

* `Gemfile`
* `.circleci/config.yml`
* `.ruby-version`

and make sure that all is still working, e.g. by opening a pull request, which will initiate a build on CircleCI.

Then, while in the project folder, download the Elastic Beanstalk environment configurations using the `eb` command-line tool, e.g. `eb config get dev`. Repeat for all of the environments:

* `dev`
* `dev-wrk`
* `prd`
* `prd-wrk`

Make sure that these files don't get committed to source control or widely shared -- they also contain secrets such as the database access password.

In each file, replace the `PlatformArn` line with the new ARN name.

Then, upload the modified files to AWS using `eb config put`, and delete the local copies. S3 will keep old versions of the configuration.

### Upgrading the Postgres client library version

Open the project file `.ebextensions/db.config`. You will see some URLs pointing to Postgres RPMs. For example:

```
'https://yum.postgresql.org/11/redhat/rhel-6-x86_64/postgresql11-libs-11.5-1PGDG.rhel6.x86_64.rpm' \
'https://yum.postgresql.org/11/redhat/rhel-6-x86_64/postgresql11-11.5-1PGDG.rhel6.x86_64.rpm' \
'https://yum.postgresql.org/11/redhat/rhel-6-x86_64/postgresql11-devel-11.5-1PGDG.rhel6.x86_64.rpm'
```

These will need to be changed -- the new version's RPMs can be found by browsing the same `yum.postgresql.org` site.

You will also need to update the symbolic link that is created below this line:

```bash
/bin/ln -s /usr/pgsql-11/bin/pg_config /usr/local/bin/pg_config
```

`pgsql-11` must be changed to `pgsql-12` (or whatever new major version is in use).

### Creating the new environment

From the ingest project directory:

```bash
export AWS_EB_CFG='dev'
export AWS_REGION='us-west-2'
rake elasticbeanstalk:create
```

This will create new worker and Web environments. Change `AWS_EB_CFG` to `prd` to rebuild the production environment.

Since this will package and deploy whatever code you have in your local copy of the project, be sure to deploy a version built on CircleCI after the environments have been created, as described above in "Releasing a new version."

After this, in the AWS Elastic Beanstalk console, find the "Swap URLs" button and use this to change DNS to point to the new environment. Delete the old environments.
