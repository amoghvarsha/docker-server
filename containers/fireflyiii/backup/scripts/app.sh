#!/bin/bash

#exec 1>/dev/null
#exec 2>/dev/null

. /app/includes.sh

function CopyData() {

    CheckDirectoryExists "${DATA_DIR}"
    CheckDirectoryExists "${STAGING_DIR}"

    # Copy data to Staging Directory
    cp -p -r "${DATA_DIR}/." "${STAGING_DIR}/"

}

function ArchiveData() {

    local ARCHIVE_FILENAME="data.tar"

    CheckDirectoryExists "${STAGING_DIR}"
    CheckDirectoryExists "${BACKUP_DIR}"

    # Archive the data
    tar -p -c -C "${STAGING_DIR}/" -f "${BACKUP_DIR}/${ARCHIVE_FILENAME}" "."

}

function GenerateBackup() {

    CopyData
    ArchiveData

}
