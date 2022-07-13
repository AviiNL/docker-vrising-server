#!/bin/bash

# Check for SteamCMD
if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "SteamCMD not found, Installing..."
    wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory ${STEAMCMD_DIR} -xvzf ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
fi

# if autoupdate is true or if vrising isnt installed yet
if [ "$AUTO_UPDATE" = true ] || [ ! -f ${SERVER_DIR}/VRisingServer.exe ]; then
    echo "Updating VRisingServer..."
    # Update SteamCMD
    ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${APP_ID} validate \
        +quit
fi

# Check if $ENABLE_BEPINEX is set to true
if [ "$ENABLE_BEPINEX" = true ]; then
    # Check if Bepinex is not installed yet
    if [ ! -f ${SERVER_DIR}/BepInEx/core/BepInEx.IL2CPP.dll ]; then
        chmod +x ${SCRIPTS_DIR}/bepinex_installer.sh
        ${SCRIPTS_DIR}/bepinex_installer.sh
    fi
else
    # Check if Bepinex is installed
    if [ -f ${SERVER_DIR}/BepInEx/core/BepInEx.IL2CPP.dll ]; then
        # Bepinex is installed, remove it
        echo "Removing BepInEx..."
        rm -rf ${SERVER_DIR}/BepInEx
        rm -rf ${SERVER_DIR}/mono
        rm -rf ${SERVER_DIR}/BepInEx-*
        rm -rf ${SERVER_DIR}/winhttp.dll
        rm -rf ${SERVER_DIR}/doorstop_config.ini
    fi
fi

export WINEARCH=win64
export WINEPREFIX=${SERVER_DIR}/WINE64

if [ "$ENABLE_BEPINEX" = true ]; then
    export WINEDLLOVERRIDES="winhttp=n,b"
fi

if [ ! -d ${SERVER_DIR}/WINE64/drive_c/windows ]; then
    echo "Setting up WINE Environment..."
    cd ${SERVER_DIR}
    winecfg > /dev/null 2>&1
    sleep 15
fi

if [ ! -d ${SERVER_DIR}/save-data/Settings ]; then
  mkdir -p ${SERVER_DIR}/save-data
  cp -R ${SERVER_DIR}/VRisingServer_Data/StreamingAssets/Settings ${SERVER_DIR}/save-data
fi

find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1

cd $SERVER_DIR

mkdir -p ${SERVER_DIR}/logs
rm -rf ${SERVER_DIR}/logs/VRisingServer.log > /dev/null 2>&1
touch ${SERVER_DIR}/logs/VRisingServer.log

if [ "$ENABLE_BEPINEX" = true ]; then
    rm -rf ${SERVER_DIR}/BepInEx/LogOutput.log > /dev/null 2>&1
    touch ${SERVER_DIR}/BepInEx/LogOutput.log
fi

echo Starting Server...

xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ${SERVER_DIR}/VRisingServer.exe -persistentDataPath ${SERVER_DIR}/save-data -serverName "${SERVER_NAME}" -saveName "${WORLD_NAME}" -logFile ${SERVER_DIR}/logs/VRisingServer.log > /dev/null 2>&1 &

if [ "$ENABLE_BEPINEX" = true ]; then
    tail -F ${SERVER_DIR}/BepInEx/LogOutput.log &
fi

tail -F ${SERVER_DIR}/logs/VRisingServer.log
