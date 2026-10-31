#!/bin/bash
# Run bitbake against an existing build directory. Does not reinitialize the project.

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

echo "Starting bitbake -k ${IMAGES}"
echo "Project files will not be reset."
bitbake -k ${IMAGES}
