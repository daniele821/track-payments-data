#!/bin/bash

# required by repo:
# `build.sh` script, which accepts 1 parameter:
#   - PATH: where to install the binary file to
#
# `decrypt.sh` script, which accepts 1 parameter:
#   - PATH: where to isntall the binary file to
# and is used to decrypt files.
# The program built accepts two parameters:
#   - KEY PATH: path to cipher key
#   - FILE PATH: patht to encrypted file

SCRIPT_PWD="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PWD}")"
DATA_DIR="${SCRIPT_DIR}/data"
DECRYPT_BIN="${DATA_DIR}/.decrypt"

# help message
if [[ -v HELP ]]; then
    echo -n 'script to auto manage different repos to track payments:

    Environment variables:
HELP=       print this help message
REPO=       specify the repository to use
    - go/golang* 
    - rust
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
    REPO_URL="https://github.com/daniele821/track-payments-rust-old"
    ;;
*)
    echo -e "\e[1;31minvalid REPO value ($REPO)\e[m"
    exit 1
    ;;
esac
REPO_DIR="$(mktemp -d)"
REPO_BIN="${DATA_DIR}/.payments_${REPO}"

# download git repository and build executable
if [[ -v PULL ]] || [[ ! -e "$REPO_BIN" ]] || [[ ! -e "$DECRYPT_BIN" ]]; then
    ! git clone "$REPO_URL" "$REPO_DIR" && echo 'failed to update repository' && exit 1

    echo -e "\e[1;33mcompiling program (payments)...\e[m" &&
        ! "$REPO_DIR/build.sh" "$REPO_BIN" &&
        echo -e "\e[1;31mcompilation failed\e[m" &&
        exit 1
    echo -e "\e[1;33mcompiling program (decrypt)...\e[m" &&
        ! "$REPO_DIR/decrypt.sh" "$DECRYPT_BIN" &&
        echo -e "\e[1;31mcompilation failed\e[m" &&
        exit 1
fi

# run executable
"${REPO_BIN}" "$@"

# cleanup
rm -rf "$REPO_DIR"
