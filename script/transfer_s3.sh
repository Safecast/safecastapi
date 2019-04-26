#!/usr/bin/env bash

set -euo pipefail

aws s3 sync --acl public-read --exclude '*$folder$' s3://safecast-production s3://safecastapi-imports-production-us-west-2
