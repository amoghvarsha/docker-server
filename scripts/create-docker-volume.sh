#!/bin/bash

# Function to create a Docker volume if it doesn't already exist, or prompt to delete and recreate it
create_volume() {
    local volume_name=$1
    if docker volume ls --format '{{.Name}}' | grep -q "^${volume_name}$"; then
        echo "Volume ${volume_name} already exists."

        read -p "Do you want to delete the existing volume and create a new one? (y/n): " choice
        case "$choice" in 
            y|Y ) 
                docker volume rm "${volume_name}"
                docker volume create "${volume_name}"
                echo "Volume ${volume_name} deleted and created."
            ;;
            n|N ) 
                echo "Volume ${volume_name} was not deleted."
            ;;
            * ) 
                echo "Invalid choice. Skipping volume ${volume_name}."
            ;;
        esac
        echo ""

    else
    docker volume create "${volume_name}"
    echo "Volume ${volume_name} created."
    echo ""
    
  fi
}

# Docker volumes for Rclone and GnuPG configuration
create_volume "backup-rclone-config"
create_volume "backup-gpg-config"

# Docker volumes for AdGuard Home
create_volume "adguardhome-work"

# Docker volumes for Firefly III database and configuration
create_volume "fireflyiii-db"
create_volume "fireflyiii-upload"

# Docker volumes for Paperless-ngx
create_volume "paperless-data"
create_volume "paperless-media"
create_volume "paperless-redisdata"

# Docker volume for Vaultwarden database
create_volume "vaultwarden-data"
