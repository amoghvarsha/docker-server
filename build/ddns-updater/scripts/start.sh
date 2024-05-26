#!/bin/bash

. /app/includes.sh

function ConfigureTimeZone() {

    ln -sf "/usr/share/zoneinfo/${TIMEZONE}" "${LOCALTIME_FILE}"

}

function ConfigureCronJob() {

    # Check if cron job exists
    local FIND_CRON_COUNT="$(grep -c 'run-ddns-updater.sh' "${CRON_CONFIG_FILE}" 2> /dev/null)"

    # Add entry if the cron job does not exist
    if [[ "${FIND_CRON_COUNT}" -eq 0 ]]
    then
        echo "${CRON} bash /app/run-ddns-updater.sh" >> "${CRON_CONFIG_FILE}"
    fi

}

########################################
# Process .env files in the directory.
# Arguments:
#     directory
# Outputs:
#     Run ddns-updater for each .env file
########################################
function RunInVerboseMode() {

    local env_dir="$1"

    for env_file in "${env_dir}"/*.env
    do
        if [[ -f "${env_file}" ]]
        then
            Echo ""
            Echo G "Processing ${env_file}"
            bash /app/ddns-updater.sh -v -R -e "${env_file}"
        else
            Echo ""
            Echo R "No .env files found in ${env_dir}"
            exit 1
        fi
    done
}

function main() {

    InitEnv

    ConfigureTimeZone
    ConfigureCronJob

    # Run once in verbose mode
    RunInVerboseMode "${ENV_DIR}"

    # foreground run crond
    exec supercronic -passthrough-logs -quiet "${CRON_CONFIG_FILE}"

    exit 0
}

main