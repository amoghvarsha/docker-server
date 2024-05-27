#!/bin/bash

ENV_FILE="/.env"
CRON_CONFIG_FILE="${HOME}/crontabs"

ZIP_TYPE="7z"

DATA_DIR="/data"
BACKUP_DIR="/backup"
STAGING_DIR="/staging"

########################################
# Print colorful message.
# Arguments:
#     color
#     message
# Outputs:
#     colorful message
########################################
function Echo() {

    if [ $# -eq 1 ]
    then

        echo "$1"

    else

        case $1 in
            R) echo -e "\033[31m$2\033[0m"
            ;;
            G) echo -e "\033[32m$2\033[0m"
            ;;
            Y) echo -e "\033[33m$2\033[0m"
            ;;
            B) echo -e "\033[34m$2\033[0m"
            ;;
        esac

    fi

}

########################################
# Check storage system configuration.
# Arguments:
#     None
########################################
function CheckRcloneConfiguration() {

    # check configuration exist
    rclone ${RCLONE_GLOBAL_FLAG} config show "${RCLONE_REMOTE_NAME}" > /dev/null 2>&1

    if [[ $? != 0 ]]
    then
        Echo R "Rclone remote '${RCLONE_REMOTE_NAME}': Not found"
        Echo B "Please configure Rclone remote"
        Echo B "Useful links: "
        Echo B "-  https://github.com/ttionya/vaultwarden-backup/blob/master/README.md#backup/"
        Echo B "-  https://rclone.org/docs/"
        exit 1
    fi

}

########################################
# Check storage system connection success.
# Arguments:
#     None
########################################
function CheckRcloneConnection() {

    rclone ${RCLONE_GLOBAL_FLAG} mkdir "${RCLONE_REMOTE_X}"

    if [[ $? != 0 ]]
    then
        Echo R "Storage system connection failure $(Echo Y "[${RCLONE_REMOTE_X}]")"
        exit 1
    fi

}

########################################
# Check if gpg exists.
# Arguments:
#     None
########################################
function CheckGPGKey() {

    gpg --list-keys "${GPG_KEY}" > /dev/null 2>&1

    if [[ $? != 0 ]]
    then
        Echo R "GPG key not found"
        exit 1
    fi
}

########################################
# Check file is exist.
# Arguments:
#     file
########################################
function CheckFileExists() {

    if [[ ! -f "$1" ]]
    then
        Echo R "Cannot access '$1': No such file"
        exit 1
    fi

}

########################################
# Check directory is exist.
# Arguments:
#     directory
########################################
function CheckDirectoryExists() {

    if [[ ! -d "$1" ]]
    then
        Echo R "Cannot access '$1': No such directory"
        exit 1
    fi

}

########################################
# Check variable is empty.
# Arguments:
#     directory
########################################
function CheckVariableIsEmpty() {

    if [[ -z "${1}" ]]
    then
        Echo R "ENV Variable '${2}', Not Specified"
        exit 1
    fi

}

########################################
# Initialization environment variables.
# Arguments:
#     None
# Outputs:
#     environment variables
########################################
function InitEnv() {

    # CRON (Optional)
    CRON="${CRON:-"5 * * * *"}"

    # RCLONE_REMOTE_NAME (Required)
    CheckVariableIsEmpty "${RCLONE_REMOTE_NAME}" "RCLONE_REMOTE_NAME"

    # RCLONE_REMOTE_DIR (Required)
    CheckVariableIsEmpty "${RCLONE_REMOTE_DIR}" "RCLONE_REMOTE_DIR"

    # get RCLONE_REMOTE_X (Required)
    RCLONE_REMOTE_X=$(echo "${RCLONE_REMOTE_NAME}:${RCLONE_REMOTE_DIR}" | sed 's@\(/*\)$@@')

    # RCLONE_GLOBAL_FLAG (Optional)
    RCLONE_GLOBAL_FLAG="${RCLONE_GLOBAL_FLAG:-""}"

    # ZIP_PASSWORD (Required)
    CheckVariableIsEmpty "${ZIP_PASSWORD}" "ZIP_PASSWORD"

    # BACKUP_KEEP_DAYS (Optional)
    BACKUP_KEEP_DAYS="${BACKUP_KEEP_DAYS:-"30"}"

    # BACKUP_FILE_DATE_FORMAT (Optional)
    BACKUP_FILE_DATE="${BACKUP_FILE_DATE:-"%Y%m%d"}"
    BACKUP_FILE_DATE_FORMAT=$(echo "${BACKUP_FILE_DATE}${BACKUP_FILE_DATE_SUFFIX}" | sed 's/[^0-9a-zA-Z%_-]//g')

    # TIMEZONE (Required)
    local TIMEZONE_MATCHED_COUNT=$(ls "/usr/share/zoneinfo/${TIMEZONE}" 2> /dev/null | wc -l)
    if [[ "${TIMEZONE_MATCHED_COUNT}" -ne 1 ]]
    then
        Echo R "Timezone, Not Specified or Found"
        exit 1
    fi

    # GPG_KEY (Required)
    CheckVariableIsEmpty "${GPG_KEY}" "GPG_KEY"

    Echo ""
    Echo Y "========================================"
    Echo Y "CRON                    : ${CRON}"
    Echo Y "RCLONE_REMOTE           : ${RCLONE_REMOTE_X}"
    Echo Y "RCLONE_GLOBAL_FLAG      : ${RCLONE_GLOBAL_FLAG}"
    Echo Y "ZIP_PASSWORD            : ${#ZIP_PASSWORD} Chars"
    Echo Y "ZIP_TYPE                : ${ZIP_TYPE}"
    Echo Y "BACKUP_FILE_DATE_FORMAT : ${BACKUP_FILE_DATE_FORMAT}"
    Echo Y "BACKUP_KEEP_DAYS        : ${BACKUP_KEEP_DAYS}"
    Echo Y "TIMEZONE                : ${TIMEZONE}"
    Echo Y "GPG_KEY                 : ${GPG_KEY}"
    Echo Y "========================================"
    Echo ""

}
