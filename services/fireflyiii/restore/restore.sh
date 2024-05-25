#!/bin/bash

docker run --rm -it                               \
  --env-file ../../../../docker-server-private/env/fireflyiii/fireflyiii-backup-secrets.env \
  -v ./scripts:/app/lib:rw                        \
  -v fireflyiii-db:/data/db:rw                    \
  -v fireflyiii-upload:/data/upload:rw            \
  -v backup-rclone-config:/root/.config/rclone:rw \
  -v backup-gpg-config:/root/.gnupg:rw            \
  restore:latest