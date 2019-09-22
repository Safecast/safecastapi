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

## Upgrading the Database

The instructions below were tested on the ingest database; as of September 2019, they have not been tested on the api database.

This process is for major version upgrades, e.g. from Postgres 9.5 to 9.6 or from 10 to 11, but not from 11.4 to 11.5. Minor version upgrades, like from 11.4 to 11.5, are automatically scheduled and performed by AWS. Read about the [the PostgreSQL versioning model](https://www.postgresql.org/support/versioning/).

### Terraform

Terraform has been configured for ingest in a way that should make it easy to perform major upgrades. If Amazon automatically performs a minor version upgrade, this will not break Terraform. In `infrastructure/terraform/ingest/main.tf`, the `engine_version` variable is set to `11` rather than `11.4` to ensure this; Terraform is aware of automatic upgrades and the Postgres versioning scheme.

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

Upgrading PostGIS is not currently supported in our Terraform configuration. To manually upgrade the PostGIS version after upgrading Postgres, see the manual instructions below.

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
