#!/bin/bash

docker run --rm -it                                \
  --env-file ../env/vaultwarden-backup.env         \
  -v ./scripts:/app/lib:rw                         \
  -v vaultwarden-data:/data:rw                     \
  -v backup-rclone-config:/root/.config/rclone:rw  \
  -v backup-gpg-config:/root/.gnupg:rw             \
  restore:latest