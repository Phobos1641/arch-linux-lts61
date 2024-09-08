#!/bin/bash -e

_version=$(pcregrep -o1 'pkgver=(.+)' PKGBUILD)
_major=${_version//.*}

_url="https://mirrors.edge.kernel.org/pub/linux/kernel/v${_major}.x/sha256sums.asc"
_checksum=$(curl -qs $_url|pcregrep -o1 '(.+)\s+linux-${_version}.tar.xz')

sed -i "s/sha256sums=(.*/sha256sums=('${_checksum}'/" PKGBUILD
