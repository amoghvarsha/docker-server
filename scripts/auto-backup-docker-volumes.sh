#!/bin/bash

# Get the absolute path to the backup directory
BACKUP_DIR=$(realpath ~/docker-server-private/volumes/backup)

# Function to backup a Docker volume
backup_volume() {
    local volume_name=$1

    echo "Backing up $volume_name..."
    docker run --rm -i \
        -v ${volume_name}:/backup \
        -v ${BACKUP_DIR}:/volume \
        debian:stable-slim \
        tar -czvf /volume/${volume_name}-backup.tar.gz /backup
}

# Main function
main() {
    # Create backup directory if it doesn't exist
    mkdir -p "${BACKUP_DIR}"

    echo "Backing up Docker volumes..."
    VOLUMES=("backup-gpg-config" "backup-rclone-config" "fireflyiii-db" "fireflyiii-upload" "linkding-data" "vaultwarden-data")
    for volume_name in ${VOLUMES[@]}; do
        backup_volume "$volume_name"
    done

    sleep 10

    cd "${BACKUP_DIR}"

    git add .
    git commit -m "Updated Backup"
    git push origin main
}

# Run the main function
main
