#!/bin/sh

PUBLIC_SYSTEM_DIR=/var/app/staging/public/system
if [ ! -e $PUBLIC_SYSTEM_DIR ]; then
  mkdir -p $PUBLIC_SYSTEM_DIR
fi
