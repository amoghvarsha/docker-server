#!/bin/bash

#exec 1>/dev/null
#exec 2>/dev/null

. /app/includes.sh
. /app/lib/app.sh

RESTORE_ZIP_FILE=""
RESTORE_GPG_FILE=""

DOWNLOAD_FILE=""

function DeleteDirectory() {

    rm -rf "${RESTORE_DIR}"
    rm -rf "${STAGING_DIR}"
}

function CreateDirectory() {

    mkdir -p "${RESTORE_DIR}"
    mkdir -p "${STAGING_DIR}"

}

function ExtractBackup() {

    CheckFileExists "${RESTORE_ZIP_FILE}"
    CheckDirectoryExists "${RESTORE_DIR}"

    7z x -p"${ZIP_PASSWORD}" "${RESTORE_ZIP_FILE}" -o"${RESTORE_DIR}/"

    if [[ $? != 0 ]]
    then
        Echo R "Decompression Failed"
        exit 1
    fi

}

function DecryptBackup() {

    CheckFileExists "${RESTORE_GPG_FILE}"

    gpg --decrypt -r "${GPG_KEY}" --output "${RESTORE_ZIP_FILE}" "${RESTORE_GPG_FILE}"

    if [[ $? != 0 ]]
    then
        Echo R "Decryption Failed"
        exit 1
    fi

}

function DownloadBackup() {

    rclone ${RCLONE_GLOBAL_FLAG} copy -M "${RCLONE_REMOTE_X}/${DOWNLOAD_FILE}" "${RESTORE_DIR}"

    if [[ $? != 0 ]]
    then
        Echo R "Download Failed"
        exit 1
    fi

}

function RunBackup() {

    read -p "Enter the Restore File Date(${RESTORE_FILE_DATE_FORMAT}): " NOW

    DOWNLOAD_FILE="backup.${NOW}.${ZIP_TYPE}.gpg"

    RESTORE_ZIP_FILE="${RESTORE_DIR}/backup.${NOW}.${ZIP_TYPE}"
    RESTORE_GPG_FILE="${RESTORE_DIR}/backup.${NOW}.${ZIP_TYPE}.gpg"

    DownloadBackup
    DecryptBackup
    ExtractBackup

    GenerateRestore
}

function main() {

    Echo B "Running the restore program at $(date +"%Y-%m-%d %H:%M:%S %Z")"

    InitEnv

    CheckRcloneConfiguration
    CheckRcloneConnection
    CheckGPGKey

    DeleteDirectory
    CreateDirectory
    RunBackup
    DeleteDirectory

    Echo B "Program Ended"

    exit 0
}

main
