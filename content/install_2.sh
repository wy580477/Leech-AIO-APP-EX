#!/bin/sh

# The URL of the script project is:
# https://github.com/XTLS/Xray-install

# Modified by wy580477 for customized container <https://github.com/wy580477>

# You can set this variable whatever you want in shell session right before running this script by issuing:
# export FILES_PATH='/usr/local/share/xray'
FILES_PATH=${FILES_PATH:-/usr/bin}

# Gobal verbals

# Xray current version
CURRENT_VERSION=''

# Xray latest release version
RELEASE_LATEST=''

# Xray version will be installed
INSTALL_VERSION=''

get_current_version() {
    # Get the CURRENT_VERSION
    if [[ -f "${FILES_PATH}/ray" ]]; then
        CURRENT_VERSION="$(${FILES_PATH}/ray -version | awk 'NR==1 {print $2}')"
        CURRENT_VERSION="v${CURRENT_VERSION#v}"
    else
        CURRENT_VERSION=""
    fi
}

get_latest_version() {
    # Get Xray latest release version number
    local tmp_file
    tmp_file="$(mktemp)"
    if ! curl -sS -H "Accept: application/vnd.github.v3+json" -o "$tmp_file" 'https://api.github.com/repos/XTLS/Xray-core/releases/latest'; then
        "rm" "$tmp_file"
        echo 'error: Failed to get release list, please check your network.'
        exit 1
    fi
    RELEASE_LATEST="$(jq .tag_name "$tmp_file" | sed 's/\"//g')"
    if [[ -z "$RELEASE_LATEST" ]]; then
        if grep -q "API rate limit exceeded" "$tmp_file"; then
            echo "error: github API rate limit exceeded"
        else
            echo "error: Failed to get the latest release version."
        fi
        "rm" "$tmp_file"
        exit 1
    fi
    "rm" "$tmp_file"
}

download_xray() {
    DOWNLOAD_LINK="https://github.com/XTLS/Xray-core/releases/download/$INSTALL_VERSION/Xray-linux-64.zip"
    if ! wget -qO "$ZIP_FILE" "$DOWNLOAD_LINK"; then
        echo 'error: Download failed! Please check your network or try again.'
        return 1
    fi
    return 0
    if ! wget -qO "$ZIP_FILE.dgst" "$DOWNLOAD_LINK.dgst"; then
        echo 'error: Download failed! Please check your network or try again.'
        return 1
    fi
    if [[ "$(cat "$ZIP_FILE".dgst)" == 'Not Found' ]]; then
        echo 'error: This version does not support verification. Please replace with another version.'
        return 1
    fi

    # Verification of Xray archive
    for LISTSUM in 'md5' 'sha1' 'sha256' 'sha512'; do
        SUM="$(${LISTSUM}sum "$ZIP_FILE" | sed 's/ .*//')"
        CHECKSUM="$(grep ${LISTSUM^^} "$ZIP_FILE".dgst | grep "$SUM" -o -a | uniq)"
        if [[ "$SUM" != "$CHECKSUM" ]]; then
            echo 'error: Check failed! Please check your network or try again.'
            return 1
        fi
    done
}

decompression() {
    busybox unzip -q "$1" -d "$TMP_DIRECTORY"
    EXIT_CODE=$?
    if [ ${EXIT_CODE} -ne 0 ]; then
        "rm" -r "$TMP_DIRECTORY"
        echo "removed: $TMP_DIRECTORY"
        exit 1
    fi
}

install_xray() {
    install -m 755 ${TMP_DIRECTORY}/xray ${FILES_PATH}/ray
}

install_geodata() {
    download_geodata() {
        if ! wget -qO "${dir_tmp}/${2}" "${1}"; then
            echo 'error: Download failed! Please check your network or try again.'
            exit 1
        fi
        if ! wget -qO "${dir_tmp}/${2}.sha256sum" "${1}.sha256sum"; then
            echo 'error: Download failed! Please check your network or try again.'
            exit 1
        fi
    }
    local download_link_geoip="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
    local download_link_geosite="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
    local file_ip='geoip.dat'
    local file_dlc='dlc.dat'
    local file_site='geosite.dat'
    local dir_tmp
    dir_tmp="$(mktemp -d)"
    download_geodata $download_link_geoip $file_ip
    download_geodata $download_link_geosite $file_site
    cd "${dir_tmp}" || exit
    for i in "${dir_tmp}"/*.sha256sum; do
        if ! sha256sum -c "${i}"; then
            echo 'error: Check failed! Please check your network or try again.'
            exit 1
        fi
    done
    cd - >/dev/null
    mv "${dir_tmp}"/${file_site} "${FILES_PATH}"/${file_site}
    mv "${dir_tmp}"/${file_ip} "${FILES_PATH}"/${file_ip}
    rm -r "${dir_tmp}"
}

# Two very important variables
TMP_DIRECTORY="$(mktemp -d)"
ZIP_FILE="${TMP_DIRECTORY}/Xray-linux-64.zip"

get_current_version
get_latest_version
INSTALL_VERSION="$RELEASE_LATEST"
if [ "${INSTALL_VERSION}" = "${CURRENT_VERSION}" ]; then
    install_geodata
    "rm" -rf "$TMP_DIRECTORY"
    exit 0
fi
download_xray
EXIT_CODE=$?
if [ ${EXIT_CODE} -eq 0 ]; then
    :
else
    "rm" -r "$TMP_DIRECTORY"
    echo "removed: $TMP_DIRECTORY"
    exit 1
fi
decompression "$ZIP_FILE"
install_xray
install_geodata
"rm" -rf "$TMP_DIRECTORY"
