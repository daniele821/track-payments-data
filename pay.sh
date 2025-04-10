#!/bin/bash

# required by repo:
# `build.sh` script, which accepts 1 parameter:
# - PATH: where to install the binary file to

SCRIPT_PWD="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PWD}")"
DATA_DIR="${SCRIPT_DIR}/data"

# help message
if [[ -v HELP ]]; then
    echo -n 'script to auto manage different repos to track payments:

    Environment variables:
HELP=       print this help message
REPO=       specify the repository to use
    -> values: go/golang, rust
PULL=       update git repo used
'
    exit 0
fi

# specify repository to use
case "${REPO}" in
"" | go | golang)
    REPO="golang"
    REPO_URL="https://github.com/daniele821/track-payments-golang"
    ;;
rust)
    REPO="rust"
    REPO_URL="https://github.com/daniele821/track-payments-rust"
    ;;
*)
    echo "invalid REPO value ($REPO)"
    exit 1
    ;;
esac
REPO_DIR="$(mktemp -d)"
REPO_BIN="${DATA_DIR}/.payments_${REPO}"

# download git repository and build executable
if [[ -v PULL ]] || [[ ! -e "$REPO_BIN" ]]; then
    ! git clone "$REPO_URL" "$REPO_DIR" && echo 'failed to update repository' && exit 1

    BUILD_EXE="$REPO_DIR/build.sh"
    if [[ ! -f "$BUILD_EXE" ]]; then
        echo "build script not found ($BUILD_EXE)"
        exit 1
    fi
    "${BUILD_EXE}" "$REPO_BIN"
fi

# run executable
"${REPO_BIN}" "$@"

# cleanup
rm -rf "$REPO_DIR"
