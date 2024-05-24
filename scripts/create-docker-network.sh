#!/bin/bash

# Function to create a Docker network
create_network() {
    local network_name=$1
    local network_driver=$2
    local subnet=$3
    local ip_range=$4
    local gateway=$5
    local options=$6

    # Check if the network already exists
    if docker network inspect $network_name > /dev/null 2>&1; then
        echo "Network $network_name already exists. Skipping creation."
    else
        # Create the Docker network
        echo "Creating Docker network $network_name..."
        docker network create \
            -d $network_driver \
            --subnet=$subnet \
            --ip-range=$ip_range \
            --gateway=$gateway \
            $options \
            $network_name

        # Check if the network was created successfully
        if [ $? -eq 0 ]; then
            echo "Docker network $network_name created successfully."
        else
            echo "Failed to create Docker network $network_name."
            exit 1
        fi
    fi
}

# Create a docker macvlan (commented out)
# create_network "docker-macvlan" "macvlan" "192.168.1.0/24" "192.168.1.0/24" "192.168.1.1" "-o parent=eth0 --ipv6=false"

# Create a docker bridge
create_network "docker-bridge" "bridge" "192.168.10.0/24" "192.168.10.0/24" "192.168.10.1" "--ipv6=false"
