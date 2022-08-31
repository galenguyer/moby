#!/usr/bin/env bash
# build and upload dockerd binaries

# exit if a command fails
set -o errexit

# exit if required variables aren't set
set -o nounset

rev="$(git rev-parse --short HEAD)"
echo "on git revision $rev"

# build the static binaries
make binary

# rename dockerd files
sha256sum bundles/binary-daemon/dockerd | cut -d " " -f 1 > bundles/binary-daemon/dockerd.sha256
md5sum bundles/binary-daemon/dockerd | cut -d " " -f 1 > bundles/binary-daemon/dockerd.md5

# sign dockerd file
gpg --output ./bundles/binary-daemon/dockerd.sig --detach-sig ./bundles/binary-daemon/dockerd

# upload to azure
if command -v rlcone &>/dev/null; then
    rclone copy --verbose ./bundles/binary-daemon/ --include="dockerd{,.md5,.sha256,.sig}" galenguyer:moby/"$(git rev-parse --short HEAD)"/
    rclone copy --verbose ./bundles/binary-daemon/ --include="dockerd{,.md5,.sha256,.sig}" galenguyer:moby/
fi
