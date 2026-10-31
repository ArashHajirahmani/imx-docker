#!/bin/bash
# This script will run into container.
# Initializes the Yocto project, then builds. Re-running it runs repo init again.

set -e

# Read from environment variables (passed from docker-run.sh)
if [ -z "$VERSION" ] || [ -z "$BRANCH" ] || [ -z "$MANIFEST" ]; then
    echo "Error: Required environment variables not set"
    echo "VERSION, BRANCH, MANIFEST, MACHINE, DISTRO, IMAGES, REMOTE must be provided"
    exit 1
fi

VERSION_DIR="imx-${VERSION}"
YOCTO_DIR="${DOCKER_WORKDIR}/${VERSION_DIR}"

echo "========================================="
echo "Building i.MX Yocto BSP"
echo "========================================="
echo "Version:  ${VERSION}"
echo "Branch:   ${BRANCH}"
echo "Manifest: ${MANIFEST}"
echo "Machine:  ${MACHINE}"
echo "Distro:   ${DISTRO}"
echo "Images:   ${IMAGES}"
echo "Remote:   ${REMOTE}"
echo "========================================="

mkdir -p ${YOCTO_DIR}
cd ${DOCKER_WORKDIR}

# Init and sync
echo "Initializing repo..."
repo init -u ${REMOTE} -b ${BRANCH} -m ${MANIFEST}

echo "Syncing repositories (this may take a while)..."
repo sync -j1

# Setup and build
echo "Setting up build environment..."
EULA=1 MACHINE="${MACHINE}" DISTRO="${DISTRO}" source imx-setup-release.sh -b build_${DISTRO}

echo 'BB_NUMBER_THREADS = "2"' >> conf/local.conf
echo 'PARALLEL_MAKE = "-j 2"' >> conf/local.conf
grep -q 'rm_work' conf/local.conf || echo 'INHERIT += "rm_work"' >> conf/local.conf

echo "Starting build..."
bitbake -k ${IMAGES}

echo ""
echo "========================================="
echo "✅ Build completed successfully!"
echo "========================================="
