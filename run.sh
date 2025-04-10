#!/bin/bash

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
'
    exit 0
fi

# specify repository to use
[[ -v REPO ]] || REPO="golang"
case "${REPO}" in
go | golang)
    REPO_URL="https://github.com/daniele821/track-payments-golang"
    REPO_DIR="${DATA_DIR}/.repo_golang"
    ;;
rust)
    REPO_URL="https://github.com/daniele821/track-payments-rust"
    REPO_DIR="${DATA_DIR}/.repo_rust"
    ;;
*)
    echo "invalid REPO value ($REPO)"
    exit 1
    ;;
esac

if [[ ! -d "$REPO_DIR" ]]; then
    git clone "$REPO_URL" "$REPO_DIR"
fi
