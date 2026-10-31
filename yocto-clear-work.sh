#!/bin/bash
# Remove generated work files from an existing build. Keeps sources, downloads,
# sstate-cache, conf, and tmp/deploy.

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -z "$DOCKER_WORKDIR" ] || [ -z "$DISTRO" ]; then
    if [ -f "${SCRIPT_DIR}/config.sh" ]; then
        # shellcheck disable=SC1091
        source "${SCRIPT_DIR}/config.sh"
    fi
fi

if [ -z "$DOCKER_WORKDIR" ] || [ -z "$DISTRO" ]; then
    echo "Error: DOCKER_WORKDIR and DISTRO must be set"
    exit 1
fi

BUILD_DIR="${DOCKER_WORKDIR}/build_${DISTRO}"
TMP_DIR="${BUILD_DIR}/tmp"

if [ ! -d "${BUILD_DIR}/conf" ]; then
    echo "Error: Build directory not found at ${BUILD_DIR}"
    exit 1
fi

if [ ! -d "${TMP_DIR}" ]; then
    echo "Nothing to clear. ${TMP_DIR} does not exist."
    exit 0
fi

# Stamps must go with the work directories. Leaving them makes bitbake
# treat missing work as already done.
CLEAR_DIRS=(
    work
    work-shared
    stamps
    sysroots
    sysroots-components
    pkgdata
    buildstats
    log
    cache
)

echo "Clearing work files in ${TMP_DIR}"
echo "Keeping sources, downloads, sstate-cache, conf, and tmp/deploy."
echo ""

for name in "${CLEAR_DIRS[@]}"; do
    path="${TMP_DIR}/${name}"
    if [ ! -e "${path}" ]; then
        continue
    fi
    size=$(du -sh "${path}" 2>/dev/null | awk '{print $1}')
    echo "Removing ${path} (${size})"
    rm -rf "${path}"
done

echo ""
echo "Work files removed."
if [ -d "${TMP_DIR}/deploy" ]; then
    echo "Images are still in ${TMP_DIR}/deploy"
fi
