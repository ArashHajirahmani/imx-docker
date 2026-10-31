#!/bin/bash
# Build the SDK for an existing image. Does not reinitialize the project.
# imx-image-full on fsl-imx-wayland includes Qt 6 and the machine-learning stack.

set -e

if [ -z "$DOCKER_WORKDIR" ] || [ -z "$DISTRO" ] || [ -z "$IMAGES" ]; then
    echo "Error: DOCKER_WORKDIR, DISTRO, and IMAGES must be set"
    exit 1
fi

BUILD_DIR="${DOCKER_WORKDIR}/build_${DISTRO}"

if [ ! -d "${DOCKER_WORKDIR}/.repo" ] || [ ! -f "${DOCKER_WORKDIR}/setup-environment" ]; then
    echo "Error: No Yocto project in ${DOCKER_WORKDIR}"
    echo "Run yocto-repo-build.sh once to initialize it."
    exit 1
fi

if [ ! -f "${BUILD_DIR}/conf/local.conf" ] || [ ! -f "${BUILD_DIR}/conf/local.conf.sample" ]; then
    echo "Error: Existing build directory not found at ${BUILD_DIR}"
    echo "This script does not create or reset the project."
    exit 1
fi

cd "${DOCKER_WORKDIR}"
# shellcheck disable=SC1091
source setup-environment "build_${DISTRO}"

echo "Starting bitbake -k ${IMAGES} -c populate_sdk"
echo "Project files will not be reset."
echo "The SDK installer will be written to ${BUILD_DIR}/tmp/deploy/sdk/"
bitbake -k ${IMAGES} -c populate_sdk
