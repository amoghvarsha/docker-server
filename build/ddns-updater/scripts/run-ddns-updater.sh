#!/bin/bash

. /app/includes.sh

########################################
# Process .env files in the directory.
# Arguments:
#     directory
# Outputs:
#     Run ddns-updater for each .env file
########################################
function Run() {

    local env_dir="$1"

    for env_file in "${env_dir}"/*.env
    do
        if [[ -f "${env_file}" ]]
        then
            Echo ""
            Echo G "Processing ${env_file}"
            bash /app/ddns-updater.sh -R -e "${env_file}"
        else
            Echo ""
            Echo R "No .env files found in ${env_dir}"
            exit 1
        fi
    done
}

function main() {

    Echo ""
    Echo B "Running the ddns update program at $(date +"%Y-%m-%d %H:%M:%S %Z")"

    InitEnv

    # Run once in verbose 
    Run "${ENV_DIR}"

    Echo ""
    Echo B "Program Ended"
    exit 0
}

main