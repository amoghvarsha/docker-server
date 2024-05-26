#!/bin/bash

EXIT_CODE=0
VERBOSE_FLAG=0
RUN_FLAG=0
TEST_FLAG=0

CURL_OPTIONS="-s -4 --connect-timeout 15"
DEFAULT_ENV_FILE="/etc/ddns-updater.d/env"
ENV_FILE=""

# Env Variables
USERNAME=""
PASSWORD=""
HOSTNAME=""
MYIP=""

ReadEnv() {
    local VAR="${1}"
    local VALUE=$(sed -n "s/^${VAR}=\(.*\)/\1/p" < "${ENV_FILE}")
    export "${VAR}=${VALUE}"
}

Echo() {
    if [ $VERBOSE_FLAG -eq 1 ]; then
        echo "$1"
    fi
}

LogAndExit() {
    local MESSAGE=$1
    local CODE=$2
    Echo "$MESSAGE"
    logger -p notice -t DDNS-UPDATER "$MESSAGE"
    exit $CODE
}

Help() {
    echo
    echo "DDNS-UPDATER Program"
    echo
    echo "Update the IP Address in DynuDNS"
    echo
    echo "Syntax : ddns-updater [ -h | -T | -R ] [ -v ] [ -e <FILE> ]"
    echo "Options :"
    echo " -h  Print Help"
    echo " -T  Test Env File"
    echo " -R  Run Program"
    echo " -v  Verbose Mode"
    echo " -e  Env File (Else, Default Env File Used)"
    echo
    echo "-- Env File Format and Variables --"
    echo "USERNAME=<?>"
    echo "PASSWORD=<?>"
    echo
    echo "-------- Optional Variables -------"
    echo "HOSTNAME=<?>"
    echo "MYIP=<?>"
    echo "-----------------------------------"
    echo
}

ParseEnvFile() {
    local RET_CODE=0

    if [ -z "$ENV_FILE" ]; then
        ENV_FILE=$DEFAULT_ENV_FILE
        if [ -f "$ENV_FILE" ]; then
            Echo "Reading default ENV file..."
        else
            LogAndExit "Default ENV file not found" 21
        fi
    else
        Echo "Reading ENV file..."
    fi

    # Extract Variables from Env File
    ReadEnv "USERNAME"
    ReadEnv "PASSWORD"
    ReadEnv "HOSTNAME"
    ReadEnv "MYIP"

    Echo 
    Echo "ENV file variables : "
    Echo
    Echo "USERNAME=$USERNAME"
    Echo "PASSWORD=${#PASSWORD} Chars"
    Echo "HOSTNAME=$HOSTNAME"
    Echo "MYIP=$MYIP"
    Echo

    if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
        LogAndExit "Variable USERNAME and/or PASSWORD not found in ENV file" 20
    fi

    return 0
}


UpdateDynuDDNS() {
    local RET_CODE=0
    local EXIT_CODE=0
    local STATUS=''
    local URL=''

    [ -z "$HOSTNAME" ] && HOSTNAME=""
    [ -z "$MYIP" ] && MYIP="10.0.0.0"

    URL="https://api.dynu.com/nic/update?username=${USERNAME}&hostname=${HOSTNAME}&password=${PASSWORD}&myip=${MYIP}&myipv6=no"

    Echo "Updating IP Address of '$HOSTNAME' in Dynu"
    STATUS="$(curl $CURL_OPTIONS "$URL")"
    EXIT_CODE="$?"

    if [ "$EXIT_CODE" -eq 0 ]; then
        set -- $STATUS
        if [ "$1" = "good" ] || [ "$1" = "nochg" ]; then
            Echo "Response Code : $1, Update successful"
            RET_CODE=0
        else
            LogAndExit "Response Code : $1, Update failed" 10
        fi
    else
        LogAndExit "Exit Code : $EXIT_CODE, Error executing 'curl'" 11
    fi

    return $RET_CODE
}

## Main Program ##

if [ $# -eq 0 ]; then
    Help
    exit 0
else
    while getopts ":hTRve:" OPTION; do
        case $OPTION in
            h)
                Help
                exit 0
                ;;
            T)
                TEST_FLAG=1
                ;;
            R)
                RUN_FLAG=1
                ;;
            v)
                VERBOSE_FLAG=1
                ;;
            e)
                ENV_FILE=$OPTARG
                if [ ! -f "$ENV_FILE" ]; then
                    echo "ENV file not found"
                    exit 1
                fi
                ;;
            \?)
                echo "Error: Invalid option"
                exit 2
                ;;
            :)
                echo "Option -$OPTARG requires an argument"
                exit 3
                ;;
        esac
    done

    if [ $TEST_FLAG -eq 1 ]; then
        Echo "Testing Env File"
        ParseEnvFile
        EXIT_CODE=$?
    elif [ $RUN_FLAG -eq 1 ]; then
        ParseEnvFile
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 0 ]; then
            UpdateDynuDDNS
            EXIT_CODE=$?
        fi
    else
        LogAndExit "Specify option -R to run or -T to test" 30
    fi

    exit $EXIT_CODE
fi
