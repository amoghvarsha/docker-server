#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 {up|down} /path/to/parent/directory"
    exit 1
}

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Set the action and parent directory from the arguments
ACTION=$1
PARENT_DIR=$2

# Validate action
if [[ "$ACTION" != "up" && "$ACTION" != "down" ]]; then
    usage
fi

# Run docker-compose command in each directory containing a docker-compose.yml file
find "$PARENT_DIR" -type f -name 'docker-compose.yml' -execdir docker compose $ACTION -d \;

