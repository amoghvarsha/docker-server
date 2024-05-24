#!/bin/bash

# Create a docker macvlan
#docker network create           \
#    -d macvlan                  \
#    --subnet=192.168.1.0/24     \
#    --ip-range=192.168.1.0/24   \
#    --gateway=192.168.1.1       \
#    -o parent=eth0              \
#    --ipv6=false                \
#    docker-macvlan

# Create a docker bridge
docker network create           \
    -d bridge                   \
    --subnet=192.168.10.0/24    \
    --ip-range=192.168.10.0/24  \
    --gateway=192.168.10.1      \
    --ipv6=false                \
    docker-bridge
