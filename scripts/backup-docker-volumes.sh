#!/bin/bash

# Get the absolute path to the backup directory
BACKUP_DIR=$(realpath ../../docker-server-private/volumes/backup)

# Function to backup a Docker volume
backup_volume() {
    local volume_name=$1
    if whiptail --yesno "Do you want to backup volume: $volume_name?" 10 60 ;then
        echo "Backing up $volume_name..."
        docker run --rm -i \
            -v ${volume_name}:/backup \
            -v ${BACKUP_DIR}:/volume \
            debian:stable-slim \
            tar -czvf /volume/${volume_name}-backup.tar.gz /backup
    else
        echo "Skipping backup of $volume_name..."
    fi
}

# Function to restore a Docker volume from backup
restore_volume() {
    local volume_name=$1
    if [ -f "$BACKUP_DIR/$volume_name-backup.tar.gz" ]; then
        if whiptail --yesno "Do you want to restore volume: $volume_name?" 10 60 ;then
           echo "Restoring $volume_name..."
            docker run --rm -i \
                -v ${volume_name}:/restore \
                -v ${BACKUP_DIR}:/volume \
                debian:stable-slim \
                tar -xzvf /volume/${volume_name}-backup.tar.gz -C /restore --strip-components=1
        else
            echo "Skipping restore of $volume_name..."
        fi
   fi
}

# Main function
main() {
    # Create backup directory if it doesn't exist
    mkdir -p "${BACKUP_DIR}"

    # Prompt user for action
    CHOICE=$(whiptail --menu "Choose an action:" 15 60 2 \
        "1" "Backup Docker volumes" \
        "2" "Restore Docker volumes" \
        3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus != 0 ]; then
        echo "User cancelled."
        exit 1
    fi

    case $CHOICE in
        1)
            # Backup Docker volumes
            echo "Backing up Docker volumes..."
            VOLUMES=$(docker volume ls --format '{{.Name}}' | tail -n +2)
            for volume_name in $VOLUMES; do
                backup_volume "$volume_name"
            done
            ;;
        2)
            # Restore Docker volumes
            echo "Restoring Docker volumes..."
            VOLUMES=$(docker volume ls --format '{{.Name}}' | tail -n +2)
            for volume_name in $VOLUMES; do
                restore_volume "$volume_name"
            done
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Run the main function
main
