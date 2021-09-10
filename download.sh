#!/bin/bash

usage()
{
cat << EOF
usage: $0 [FileName]
Uploads files to Gofile
OPTIONS:
    -w        Steam workshop ID. If specified, it downloads a Steam workshop item instead of updating server files.
              Workshop content requires logging in with a Steam account that owns DayZ.

    -h        Show this message
EOF
}

WORKSHOP_ID="";
while getopts "hw:" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        w)
            WORKSHOP_ID="${OPTARG}";
            IS_WORKSHOP=1;
            echo "Attempting to download Steam workshop item: ${WORKSHOP_ID}";
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

if [[ -z "${BASE_DIR}" ]]; then
    BASE_DIR="$(dirname $(realpath $0))";
fi
SERVER_FILES="${BASE_DIR}/server_files";
WORKSHOP_FILES="${BASE_DIR}/workshop_mods";

if [[ ! -d "${SERVER_FILES}" ]]; then
    echo "Creating folder for storing server files: '${SERVER_FILES}'";
    mkdir -p "${SERVER_FILES}";
fi

if [[ ! -d "${WORKSHOP_FILES}" ]]; then
    echo "Creating folder for storing workshop mod files: '${WORKSHOP_FILES}'";
    mkdir -p "${WORKSHOP_FILES}";
fi

# Check if already specified via environment variable
# Note: I have no idea what happens if you switch between exp/stable without clearing the
#       existing server files. Might be some conflicts?
if [[ -z "${STEAM_APP_ID}" ]]; then
    # Experimental
    STEAM_APP_ID=1042420

    # Stable
    # As of 2021-09-09, stable does NOT support Linux yet and therefore won't work.
    # STEAM_APP_ID=223350
fi

DATA_VOLUME="${SERVER_FILES}";
STEAMCMD_PARAMS="+app_update ${STEAM_APP_ID} validate";
STEAM_USERNAME="anonymous";

# Modify the command if a workshop ID is specified.
# Note: I am not entirely sure if this is the correct method.
if [[ ! -z "${WORKSHOP_ID}" ]]; then
    echo "Steam username: ";
    read STEAM_USERNAME;

    echo "Name of mod (Steam workshop item):";
    read WORKSHOP_MOD_NAME;

    DATA_VOLUME="${WORKSHOP_FILES}";
    STEAMCMD_PARAMS="+workshop_download_item 221100 ${WORKSHOP_ID} validate";
fi

docker run -it \
    -v "${DATA_VOLUME}":/data \
    -v "${BASE_DIR}/.steamcmd":/root/.steam \
    steamcmd/steamcmd:latest +login "${STEAM_USERNAME}" +force_install_dir /data \
    $STEAMCMD_PARAMS \
    +quit;

if [[ ! -z "${WORKSHOP_ID}" && ! -z "${WORKSHOP_MOD_NAME}" ]]; then
    ORIG_MOD_FOLDER="${WORKSHOP_FILES}/steamapps/workshop/content/221100/${WORKSHOP_ID}";
    MOD_NAME_FOLDER="${SERVER_FILES}/${WORKSHOP_MOD_NAME}";
    mkdir -p "${MOD_NAME_FOLDER}";
    cp -r "${ORIG_MOD_FOLDER}"/* "${MOD_NAME_FOLDER}";
    cp -r "${ORIG_MOD_FOLDER}/Keys"/* "${SERVER_FILES}/keys";

    echo;
    echo "Workshop/mod files copied to: ${MOD_NAME_FOLDER}";
fi
