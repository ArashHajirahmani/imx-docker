#!/bin/bash
# Load an existing i.MX build so bitbake can be run by hand.
# Does not run repo init and does not rewrite the build configuration.

yocto_launch_main() {
    if [ -z "$DOCKER_WORKDIR" ] || [ -z "$DISTRO" ]; then
        echo "Error: DOCKER_WORKDIR and DISTRO must be set" >&2
        return 1
    fi

    local build_dir="${DOCKER_WORKDIR}/build_${DISTRO}"

    if [ ! -d "${DOCKER_WORKDIR}/.repo" ] || [ ! -f "${DOCKER_WORKDIR}/setup-environment" ]; then
        echo "Error: No Yocto project in ${DOCKER_WORKDIR}" >&2
        echo "Run yocto-repo-build.sh once to initialize it." >&2
        return 1
    fi

    if [ ! -f "${build_dir}/conf/local.conf" ] || [ ! -f "${build_dir}/conf/local.conf.sample" ]; then
        echo "Error: Existing build directory not found at ${build_dir}" >&2
        echo "Run yocto-repo-build.sh once to create it. This script will not create or reset one." >&2
        return 1
    fi

    cd "${DOCKER_WORKDIR}" || return 1
    # shellcheck disable=SC1091
    source setup-environment "build_${DISTRO}"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    yocto_launch_main || exit 1
    echo "BitBake environment is ready in ${BUILDDIR}."
    echo "Configuration was not modified."
    exec bash -i
else
    yocto_launch_main || return 1
fi
