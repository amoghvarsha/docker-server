#!/bin/bash

. /app/includes.sh

function ConfigureTimeZone() {

    ln -sf "/usr/share/zoneinfo/${TIMEZONE}" "${LOCALTIME_FILE}"

}

function ConfigureCronJob() {

    # Check if cron job exists
    local FIND_CRON_COUNT="$(grep -c 'backup.sh' "${CRON_CONFIG_FILE}" 2> /dev/null)"

    # Add entry if the cron job does not exist
    if [[ "${FIND_CRON_COUNT}" -eq 0 ]]
    then
        echo "${CRON} bash /app/backup.sh" >> "${CRON_CONFIG_FILE}"
    fi

}

function main() {

    InitEnv

    CheckRcloneConfiguration
    CheckRcloneConnection
    CheckGPGKey

    ConfigureTimeZone
    ConfigureCronJob

    # foreground run crond
    exec supercronic -passthrough-logs -quiet "${CRON_CONFIG_FILE}"

    exit 0
}

main
