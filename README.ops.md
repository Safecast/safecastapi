## Deployment on AWS

### Pre-requisites

* A login for the `safecast` AWS account ([contact mat](mailto:mat@schaffer.me))
* The `safecastapi` private SSH key ([contact mat](mailto:mat@schaffer.me))

* AWS CLI & ElasticBeatnstalk CLI
  * Run `pip install -r requirements.txt` under a python virtualenv ([direnv](https://direnv.net/) makes virtualenvs easy)

* Terraform
  * [tfenv](https://github.com/tfutils/tfenv) is recommended as terraform versions will change over time

* A configured `safecast` AWS profile (`aws configure --profile safecast`)

### Guide

To create a new environment pair (worker & web), you'll need DB connection info first. You can get this by creating a new RDS (ideally via terraform) or using the info from an existing environment. Once you've got that info, run the rake task to create the env.

```
AWS_EB_DATABASE_HOST=... \
AWS_EB_DATABASE_PASSWORD=... \
AWS_EB_CFG=(dev/prd/whatever) \
rake elasticbeanstalk:create
```

The environment name will be numeric based on existing environments of the same config name.

If you're working against an empty DB, you can run `rds:structure:load` to load a patched version of our `structure.sql` that's RDS-compatible.

If you need to run any rails commands to debug anything you can do this:

```
eb ssh (environment name)
cd /var/app/current   # or /var/app/ondeck for any failed deployment assets
bundle exec rails c   # or whatever command you need
```
