#!/bin/sh
/usr/bin/Xvfb :99 -screen 0 1280x1024x24 &
exec "$@"
