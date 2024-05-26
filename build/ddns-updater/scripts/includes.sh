#!/bin/bash

CRON_CONFIG_FILE="${HOME}/crontabs"

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
# Check if directory is empty.
# Arguments:
#     directory
########################################
function CheckDirectoryIsEmpty() {
    if [ -d "$1" ]; then
        if [ -z "$(ls -A "$1")" ]; then
            Echo R "Directory '$1' is empty"
        fi
    else
        Echo R "Cannot access '$1': No such directory"
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

    # ENV default directory
    ENV_DIR="${ENV_DIR:-"/env.d"}"

    # Check env directory exists
    CheckDirectoryExists "${ENV_DIR}"

    # Check if env directory is empty 
    CheckDirectoryIsEmpty "${ENV_DIR}"
    
    # CRON (Optional)
    CRON="${CRON:-"*/2 * * * *"}"

    # TIMEZONE (Required)
    local TIMEZONE_MATCHED_COUNT=$(ls "/usr/share/zoneinfo/${TIMEZONE}" 2> /dev/null | wc -l)
    if [[ "${TIMEZONE_MATCHED_COUNT}" -ne 1 ]]
    then
        Echo R "Timezone, Not Specified or Found"
        exit 1
    fi

    Echo ""
    Echo Y "========================================"
    Echo Y "ENV_DIR  : ${ENV_DIR}"
    Echo Y "CRON     : ${CRON}"
    Echo Y "TIMEZONE : ${TIMEZONE}"
    Echo Y "========================================"

}
