#!/bin/sh
# Connects this machine to an Ada desktop (docs/machines.md).
#
#   curl -fsSL https://github.com/Ifesol-backup/ada-remote/releases/latest/download/install.sh | sh -s -- <invite>
#
# Downloads ada-remote for this machine, checks it, and joins the desktop
# that made the invite. No root needed; nothing listens on a public port.
# Published with each ada-remote release, next to the binaries.
set -eu

invite="${1:-}"
if [ -z "$invite" ]; then
    echo "Ada: copy the whole line from your desktop (Files → Machines → Connect); it ends with your invite." >&2
    exit 2
fi
base="${ADA_REMOTE_BASE:-https://github.com/Ifesol-backup/ada-remote/releases/latest/download}"

if [ "$(uname -s)" != Linux ]; then
    echo "Ada: ada-remote runs on Linux machines." >&2
    exit 1
fi
case "$(uname -m)" in
    x86_64 | amd64) arch=x86_64 ;;
    aarch64 | arm64) arch=aarch64 ;;
    *)
        echo "Ada: this machine's processor ($(uname -m)) isn't supported yet." >&2
        exit 1
        ;;
esac

fetch() {
    if command -v curl > /dev/null 2>&1; then
        curl -fsSL --retry 3 "$1" -o "$2"
    elif command -v wget > /dev/null 2>&1; then
        wget -q -O "$2" "$1"
    else
        echo "Ada: this machine needs curl or wget." >&2
        exit 1
    fi
}

sha256() {
    if command -v sha256sum > /dev/null 2>&1; then
        sha256sum "$1" | cut -d' ' -f1
    elif command -v shasum > /dev/null 2>&1; then
        shasum -a 256 "$1" | cut -d' ' -f1
    elif command -v openssl > /dev/null 2>&1; then
        openssl dgst -sha256 "$1" | sed 's/.*= *//'
    else
        echo ""
    fi
}

tmp=$(mktemp -d 2> /dev/null || mktemp -d -t ada-remote)
trap 'rm -rf "$tmp"' EXIT INT TERM

echo "Ada: downloading ada-remote…"
fetch "$base/ada-remote-$arch" "$tmp/ada-remote"
fetch "$base/ada-remote-$arch.sha256" "$tmp/ada-remote.sha256"
expected=$(cut -d' ' -f1 < "$tmp/ada-remote.sha256")
actual=$(sha256 "$tmp/ada-remote")
if [ -n "$actual" ] && [ "$expected" != "$actual" ]; then
    echo "Ada: the download was damaged. Run the line again." >&2
    exit 1
fi
chmod 755 "$tmp/ada-remote"

# `join` copies ada-remote into its own folder and starts it as a service.
"$tmp/ada-remote" join "$invite"
