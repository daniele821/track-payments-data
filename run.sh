#!/bin/bash

# required by repo:
# `build.sh` script, which accepts 2 parameters:
# - PATH: where to install the binary file to
# - payments|decrypt: specify what the binary file is for

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
[[ -v REPO ]] || REPO="golang"
case "${REPO}" in
go | golang)
    REPO_URL="https://github.com/daniele821/track-payments-golang"
    REPO_DIR="${DATA_DIR}/.repo_golang"
    REPO_BIN="${DATA_DIR}/.payments_golang"
    ;;
rust)
    REPO_URL="https://github.com/daniele821/track-payments-rust"
    REPO_DIR="${DATA_DIR}/.repo_rust"
    REPO_BIN="${DATA_DIR}/.payments_rust"
    ;;
*)
    echo "invalid REPO value ($REPO)"
    exit 1
    ;;
esac

# download git repository and optionally update
if [[ ! -d "$REPO_DIR" ]]; then
    ! git clone "$REPO_URL" "$REPO_DIR" && echo 'failed to update repository' && exit 1
elif [[ -v PULL ]]; then
    ! git -C "$REPO_DIR" pull && echo 'failed to update repository' && exit 1
fi

# build executable
BUILD_EXE="$REPO_DIR/build.sh"
if [[ ! -f "$BUILD_EXE" ]]; then
    echo "build script not found ($BUILD_EXE)"
    exit 1
fi
"${BUILD_EXE}" "$REPO_BIN" "payments"

# run executable
"${REPO_BIN}" "$@"
