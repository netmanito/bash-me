#!/bin/bash
source common/common.sh
source common/management.sh
# exit on error
set -e

# Check correct parameters
USAGE="Usage: $0 <option bashme,m | uninstall,u | bashrc,b | help,h>"
EXPECTED=1
INTRO=$#
EXAMPLE="Example: $0 me"

if [[ $INTRO -lt $EXPECTED ]]; then
        log ERROR "Too few arguments. ❌"
        log INFO "$USAGE"
        log INFO "$EXAMPLE"
        exit 1
fi


# Check if bash-me is configured in .bashrc
bash_check() {
    grep -q bash-me "${HOME}"/.bashrc
    return $?
}

# variables to work in requests
BRANCH="bashrcs"
COMMAND=$1

# temp file
TMP_FILE=$(mktemp -q "${PWD}"/bash-me.XXXXXX)
trap 'rm -f $TMP_FILE' 0 2 3 15

# case commands: bash-me, bash-u, bash-r
case $COMMAND in
bashme | m)
    log INFO "Installing BashMe aliases"
    deployBashMe
    ;;
bashrc | b)
    log INFO "Updating .bashrc file"
    setNewBashrc
    ;;
uninstall | d)
    log INFO "Uninstalling BashMe"
    destroyBashMe
    ;;
help | h)
    log INFO "Displaying help"
    help
    ;;
*)
    log ERROR "Invalid command: $COMMAND"
    echo "$USAGE"
    exit 1
    ;;
esac
shift
