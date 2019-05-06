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
SELECT pid, age(clock_timestamp(), query_start), usename, client_addr, query, state
FROM pg_stat_activity
WHERE state != 'idle' AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start desc;  
```

If you have many long running queries, you can terminate older queries using something like this to terminate any query that's been running longer than 5 minutes.

```
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%' AND query_start < NOW() - interval '5 minutes';
```

Cron jobs are handled via elastic beanstalk's aws-sqsd which can also back up if the DB is slow for an extended period of time.

If this happens, the messages in flight will be high (more than 1 or 2). Clearing the SQS queue via [the AWS console](https://console.aws.amazon.com/sqs/home?region=us-west-2) can be a good idea to ensure we're not re-computing any jobs.

The production queue should be `awseb-e-aaw6am7e2x-stack-AWSEBWorkerQueue-3WZCP00RYHUX` which can be verified by the `Name` tag on the queue.
