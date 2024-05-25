#!/bin/bash

docker run --rm -it                                \
  --env-file ../../../../docker-server-private/env/vaultwarden/vaultwarden-backup-secrets.env \
  -v ./scripts:/app/lib:rw                         \
  -v vaultwarden-data:/data:rw                     \
  -v backup-rclone-config:/root/.config/rclone:rw  \
  -v backup-gpg-config:/root/.gnupg:rw             \
  restore:latest