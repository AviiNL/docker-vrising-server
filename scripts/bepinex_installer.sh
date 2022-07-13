#!/bin/bash

if [ ! "${ENABLE_BEPINEX}" == "true" ]; then
    echo Aborting Bepinex installation, ENABLE_BEPINEX is not set to true
    exit 0
fi

# If SERVER_DIR is not defined, grab from command line argument
if [ -z "${SERVER_DIR}" ]; then
    SERVER_DIR="$1"
fi

if [ -z "${SERVER_DIR}" ]; then
    echo "SERVER_DIR is not defined, please define it in the script or pass it as an argument"
    exit 1
fi

BEPINEX_VR_TS_API_URL=https://thunderstore.io/c/v-rising/api/v1/package/b86fcaaf-297a-45c8-82a0-fcbd7806fdc4/
BEPINEX_VR_TS_URL=https://v-rising.thunderstore.io/package/BepInEx/BepInExPack_V_Rising/

BEPINEX_DATA=$(curl -s ${BEPINEX_VR_TS_API_URL})

BEPINEX_LATEST_VERSION=$(echo ${BEPINEX_DATA} | jq -r '.versions[0].version_number')
BEPINEX_DOWNLOAD_URL=$(echo ${BEPINEX_DATA} | jq -r '.versions[0].download_url')

INSTALLED_VERSION="$(find ${SERVER_DIR} -maxdepth 1 -name "BepInEx-*" | cut -d '-' -f2)"

# If the INSTALLED_VERSION matches BEPINEX_LATEST_VERSION, don't do anything
if [ "${INSTALLED_VERSION}" == "${BEPINEX_LATEST_VERSION}" ]; then
    exit 0
fi

echo "Installing Bepinex ${BEPINEX_LATEST_VERSION}..."

# Download Bepinex to using wget into /tmp
wget -q -O /tmp/BepInEx.zip ${BEPINEX_DOWNLOAD_URL}
unzip -o -q /tmp/BepInEx.zip -d /tmp/bepinex
cp -r /tmp/bepinex/BepInEx*/* ${SERVER_DIR}/
# cleanup
rm -rf /tmp/bepinex
rm -rf /tmp/BepInEx.zip
touch ${SERVER_DIR}/BepInEx-${BEPINEX_LATEST_VERSION}
