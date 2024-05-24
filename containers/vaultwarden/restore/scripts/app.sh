#!/bin/bash

#exec 1>/dev/null
#exec 2>/dev/null

. /app/includes.sh

function RestoreData() {

    CheckDirectoryExists "${DATA_DIR}"
    CheckDirectoryExists "${STAGING_DIR}"

    # Copy data to Staging Directory
    cp -p -r "${STAGING_DIR}/." "${DATA_DIR}/"

}

function ExtractData() {

    local ARCHIVE_FILENAME="data.tar"

    CheckDirectoryExists "${STAGING_DIR}"
    CheckDirectoryExists "${RESTORE_DIR}"

    # Archive the data
    tar -p -x -C "${STAGING_DIR}/" -f "${RESTORE_DIR}/${ARCHIVE_FILENAME}"

}

function GenerateRestore() {

    ExtractData
    RestoreData
}