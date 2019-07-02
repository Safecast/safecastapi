#!/usr/bin/env bash

# Packages and uploads the app for elasticbeanstalk deployment
#
# Expected environment variables (or circleci equivalents)
#   Provided by caller
#     - AWS_DEFAULT_REGION
#     - S3_BUCKET_NAME
#     - EB_APP_NAME
#
#   Provided by CI
#     - BRANCH_NAME
#     - BUILD_NUMBER
#
# Usage: .elasticbeanstalk/package.sh APP
# Ex: .elasticbeanstalk/package.sh ${SEMAPHORE_PROJECT_NAME}

set -euxo pipefail

BRANCH_NAME="${CIRCLE_BRANCH:-${BRANCH_NAME}}"
BUILD_NUMBER="${CIRCLE_BUILD_NUM:-${BUILD_NUMBER}}"
DESCRIPTION="${CIRCLE_BUILD_URL:-${DESCRIPTION}}"

CLEAN_BRANCH_NAME="${BRANCH_NAME//\//_}"
CLEAN_DESCRIPTION="${DESCRIPTION/https*:\/\//}"

VERSION="${EB_APP_NAME}-${CLEAN_BRANCH_NAME}-${BUILD_NUMBER}"

PACKAGE="${VERSION}.zip"

cp config/database.yml.beanstalk config/database.yml

.elasticbeanstalk/package.py "${PACKAGE}"

aws s3 cp --no-progress ".elasticbeanstalk/app_versions/${PACKAGE}" "s3://${S3_BUCKET_NAME}/${EB_APP_NAME}/"

aws elasticbeanstalk create-application-version \
    --debug \
    --region "${AWS_DEFAULT_REGION}" \
    --application-name "${EB_APP_NAME}" \
    --version-label "${VERSION}" \
    --source-bundle "S3Bucket=${S3_BUCKET_NAME},S3Key=${EB_APP_NAME}/${PACKAGE}" \
    --description "${CLEAN_DESCRIPTION}" \
    --process
