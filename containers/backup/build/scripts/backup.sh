#!/bin/bash

#exec 1>/dev/null
#exec 2>/dev/null

. /app/includes.sh
. /app/lib/app.sh

BACKUP_ZIP_FILE=""
BACKUP_GPG_FILE=""

UPLOAD_FILE=""

function DeleteDirectory() {

    rm -rf "${BACKUP_DIR}"
    rm -rf "${STAGING_DIR}"
}

function CreateDirectory() {

    mkdir -p "${BACKUP_DIR}"
    mkdir -p "${STAGING_DIR}"
}

function ClearBackupHistory() {

    if [[ "${BACKUP_KEEP_DAYS}" -gt 0 ]]
    then
        mapfile -t RCLONE_DELETE_LIST < <(rclone ${RCLONE_GLOBAL_FLAG} lsf "${RCLONE_REMOTE_X}" --min-age "${BACKUP_KEEP_DAYS}d")

        for RCLONE_DELETE_FILE in "${RCLONE_DELETE_LIST[@]}"
        do
            rclone ${RCLONE_GLOBAL_FLAG} delete "${RCLONE_REMOTE_X}/${RCLONE_DELETE_FILE}"
            if [[ $? != 0 ]]
            then
                Echo R "Delete \"${RCLONE_DELETE_FILE}\" Failed"
            fi
        done
    fi
}

function CompressBackup() {

    CheckDirectoryExists "${BACKUP_DIR}"

    7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mhe=on -p"${ZIP_PASSWORD}" "${BACKUP_ZIP_FILE}" "${BACKUP_DIR}/*"

    if [[ $? != 0 ]]
    then
        Echo R "Compression Failed"
        exit 1
    fi
}

function EncryptBackup() {

    CheckFileExists "${BACKUP_ZIP_FILE}"

    gpg --encrypt -r "${GPG_KEY}" --output "${BACKUP_GPG_FILE}" "${BACKUP_ZIP_FILE}"

    if [[ $? != 0 ]]
    then
        Echo R "Encryption Failed"
        exit 1
    fi
}

function UploadBackup() {

    CheckFileExists "${UPLOAD_FILE}"

    rclone ${RCLONE_GLOBAL_FLAG} copy "${UPLOAD_FILE}" "${RCLONE_REMOTE_X}"

    if [[ $? != 0 ]]
    then
        Echo R "Upload Failed"
        exit 1
    fi
}

function RunBackup() {

    local NOW="$(date +"${BACKUP_FILE_DATE_FORMAT}")"

    BACKUP_ZIP_FILE="${BACKUP_DIR}/backup.${NOW}.${ZIP_TYPE}"
    BACKUP_GPG_FILE="${BACKUP_ZIP_FILE}.gpg"

    UPLOAD_FILE="${BACKUP_GPG_FILE}"

    GenerateBackup
    CompressBackup
    EncryptBackup
    UploadBackup
}

function main() {

    Echo B "Running the backup program at $(date +"%Y-%m-%d %H:%M:%S %Z")"

    InitEnv

    CheckRcloneConfiguration
    CheckRcloneConnection
    CheckGPGKey

    DeleteDirectory
    CreateDirectory
    RunBackup
    DeleteDirectory

    ClearBackupHistory

    Echo B "Program Ended"

    exit 0
}

main
