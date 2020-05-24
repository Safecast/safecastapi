#!/usr/bin/env python3

import pprint
import sys
if sys.version_info.major < 3 or sys.version_info.minor < 7:
    print("Error: This script requires at least Python 3.7.", file=sys.stderr)
    exit(1)

import boto3

ebclient = boto3.client('elasticbeanstalk')

versions = ebclient.describe_application_versions(
    ApplicationName='api'
    )

pprint.pprint(versions)
