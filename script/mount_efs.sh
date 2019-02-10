#!/usr/bin/env bash

set -euo pipefail

AWS_EFS_VOLUME="${1:-}"

if [[ -z "${AWS_EFS_VOLUME}" ]]; then
  echo "Usage: $0 <EFS-volume-id>"
  exit 1
fi

mkdir -p /mnt/efs

if ! grep -q "${AWS_EFS_VOLUME}" /etc/fstab; then
    cat <<FSTAB >> /etc/fstab
${AWS_EFS_VOLUME}:/ /mnt/efs efs defaults,_netdev 0 0
FSTAB
fi

mountpoint -q /mnt/efs || mount /mnt/efs

mkdir -p /mnt/efs/shared/system
chown webapp:webapp /mnt/efs/shared/system
