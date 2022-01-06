#!/bin/bash

# Update server files
/usr/games/steamcmd +force_install_dir /server +login arg_gifi HnAmdA.p69_rB-c +app_update $STEAM_APP_ID validate +quit

# Run server
/server/DayZServer -cpuCount=$CPU_COUNT -dologs -adminlog -netlog -freezecheck -profiles="${PROFILE_DIR}" -config="${CONFIG_FILE}"
