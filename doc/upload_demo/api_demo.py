import sys

import requests
import os

endpoint = os.environ.get("SAFECAST_API", "https://api.safecast.org")
api_key = os.environ.get("SAFECAST_API_KEY")

if len(sys.argv) != 2:
    print("Usage: {} <LOGFILE>".format(sys.argv[0]), file=sys.stderr)
    sys.exit(1)

bgeigie_log = sys.argv[1]

auth_params = {'api_key': api_key}
default_headers = {'Accept': 'application/json'}

# Post the file

file_params = {
    'bgeigie_import[source]': (
        os.path.basename(bgeigie_log),
        open(bgeigie_log, 'r')
    )
}

response = requests.post(
    '{}/bgeigie_imports'.format(endpoint),
    auth_params,
    files=file_params,
    headers=default_headers,
)

response.raise_for_status()
import_id = response.json()['id']
print("Imported {} as ID {}".format(bgeigie_log, import_id))

# Add metadata

import_metadata = {
    'bgeigie_import': {
        'name': 'A test file',
        'description': 'A test file',
        'credits': 'Mat Schaffer',
        'cities': 'Hokuto',
        'comment': 'Just testing',
        'height': 1,
        'orientation': 'Facing left',
        'subtype': 'Drive'
    }
}

response = requests.patch(
    '{}/bgeigie_imports/{}'.format(endpoint, import_id),
    params=auth_params,
    headers=default_headers,
    json=import_metadata,
)
response.raise_for_status()
print("Updated metadata on import ID {}".format(import_id))

# Submitting for approval

response = requests.put(
    '{}/bgeigie_imports/{}/submit'.format(endpoint, import_id),
    params=auth_params,
    headers=default_headers,
)
response.raise_for_status()
print("Submitted import ID {} for approval".format(import_id))
