#!/bin/sh -e
# under GPLv2
# heavily influenced by OpenWrt/LEDE scripts/getver.sh
#                    by coreboot util/genbuild_h/genbuild_h.sh

export LANG=C
export LC_ALL=C
export TZ=UTC

# top directory of the squashfs, used for git detection
TOP="$1"
OUTPUT="$2"
REV=""
_SOURCE_DATE_EPOCH=""

if [ "$#" -gt 2 ] ; then
	echo "$0 [[<topdir>] <outputfile>]"
fi

if [ -z "$TOP" ] ; then
	TOP="$(dirname "$0")/.."
fi

if [ -z "$OUTPUT" ] ; then
	OUTPUT="squashfs-tools/version.h"
fi

our_date() {
case $(uname) in
NetBSD|OpenBSD|DragonFly|FreeBSD|Darwin)
        date -r "$1" "$2"
        ;;
*)
        date -d "@$1" "$2"
esac
}

try_version() {
        [ -f version ] && [ -f version.date ] || return 1
        REV="$(cat version)"
        _SOURCE_DATE_EPOCH="$(cat version.date)"

        [ -n "$REV" ] && [ -n "$_SOURCE_DATE_EPOCH" ]
}

try_git() {
	[ -d .git ] || return 1

	REV="$(git describe --tags 2>/dev/null)"
	_SOURCE_DATE_EPOCH="$(git log -1 --format=format:%ct)"

        [ -n "$REV" ] && [ -n "$_SOURCE_DATE_EPOCH" ]
}

try_source_date_epoch() {
    # tries to use the environment
    if [ -n "$SOURCE_DATE_EPOCH" ] ; then
        _SOURCE_DATE_EPOCH="$SOURCE_DATE_EPOCH"
    fi
}

output_version() {
	echo "Writing $OUTPUT"
	DATE="$(our_date "$_SOURCE_DATE_EPOCH" +%Y/%m/%d)"
	cat > "$OUTPUT" <<EOF
#define VERSION_STR "squashfskit-$REV"
#define VERSION_DATE_STR "$DATE"
EOF
}

cd "$TOP"
try_git || try_version || try_source_date_epoch || _SOURCE_DATE_EPOCH="2"
output_version
