#!/usr/bin/env python

"""
Helper for creating a zip file for consumption by elasticbeanstalk.

Runs similar code to `eb deploy` from ebcli, but will just create the zipfile. This allows us to be specific about
the name and bind it to our branch & build number for later deployment.
"""

import logging
import sys
import ebcli.core.fileoperations as fileoperations

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

if len(sys.argv) != 2:
    print("Usage: {} FILENAME".format(sys.argv[0]))
    print("Ex: {} myapp-BRANCH-BUILDNUMBER.zip".format(sys.argv[0]))
    sys.exit(1)

file_name = sys.argv[1]
file_path = fileoperations.get_zip_location(file_name)

logging.info('Packaging application to %s', file_path)
ignore_files = fileoperations.get_ebignore_list()
fileoperations.io.log_info = lambda message: logging.debug(message)
fileoperations.zip_up_project(file_path, ignore_list=ignore_files)
