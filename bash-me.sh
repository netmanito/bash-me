#!/bin/bash
source common/common.sh
source common/management.sh
# exit on error
set -e

# Check correct parameters
USAGE="Usage: $0 <option bashme,me | bashrc,rc | destroy,d | help,h>"
EXPECTED=1
INTRO=$#
EXAMPLE="Example: $0 me"

if [[ $INTRO -lt $EXPECTED ]]; then
        echo "ERROR" "Too few arguments. ❌"
        echo
        echo "$USAGE"
        echo
        echo "$EXAMPLE"
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
bashme | me)
        echo
        echo "Installing BashMe aliases"
        deployBashMe
        echo
        ;;
bashrc | rc)
        echo
        echo "Updating .bashrc file"
        setNewBashrc
        echo
        ;;
destroy | d)
        echo
        echo "Deleting bashMe"
        destroyBashMe
        echo
        ;;
help | h)
        echo ""
        help
        echo ""
        ;;
*)
        echo "Fail"
        ;;

esac
shift
