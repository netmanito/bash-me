#!/bin/bash

# exit on error
set -e


# Check correct parameters
USAGE="Usage: $0 <option me | bashrc,rc | update,u >"
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

# Check if bash-me was previously installed
findBashMe() {
        find ~/ -iname .bash-me
}

ALIASES=$(findBashMe)

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

# functions

function dumpBashMeFiles() {
        # Install procedure
        if [ -z "$ALIASES" ]; then
                # Check if working from repository or remote execution
                echo "Checking required files"
                if [ ! -f bash-files/bash-aliases-extra ]; then
                        echo "bash-files/bash-aliases-extra not found, downloading ..."
                        echo "Downloading bash aliases extra"
                        curl https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bash-aliases-extra.txt >> "$TMP_FILE"
                else
                        echo "..."
                        echo "# bash-me extra functionalities" >~/.bash-me
                        cat ./bash-files/bash-aliases-extra.txt >>~/.bash-me
                fi
                if [ ! -f bash-files/bash-aliases-functions ]; then
                        echo "bash-files/bash-aliases-functions not found, downloading ..."
                        echo "Downloading bash aliases functions"
                        curl https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bash-aliases-functions.txt >> "$TMP_FILE"
                else
                        echo "updating bash-me"
                        cat ./bash-files/bash-aliases-functions.txt >>~/.bash-me
                fi
                echo "no .bash-me found, creating it for you"
                read -r -p "Press ENTER to continue"
                echo "..."
                cat "$TMP_FILE" >>"${HOME}"/.bash-me
                echo "adding bash-me to .bashrc"

                if bash_check; then
                        echo "bash-me already in .bashrc"
                        echo "No changes needed"
                else
                        echo "bash-me not found in .bashrc"
                        echo "Configuring ..."
                        echo "if [ -f ~/.bash-me ]; then" >>~/.bashrc
                        echo "    source ~/.bash-me" >>~/.bashrc
                        echo "fi" >>~/.bashrc
                        # shellcheck source=/dev/null
                        source ~/.bashrc
                fi
        else
                echo ".bash-me found on your home directory"
                echo "Do you want to update?"
                read -p "y/n: " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                        # Check if files are already downloaded
                        if [ ! -f bash-files/bash-aliases-extra ]; then
                                echo "bash-files/bash-aliases-extra not found, downloading ..."
                                curl https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bash-aliases-extra.txt >> "$TMP_FILE"
                        else
                                cat ./bash-files/bash-aliases-extra.txt >>"$TMP_FILE"
                        fi
                        if [ ! -f bash-files/bash-aliases-functions ]; then
                                echo "bash-aliases-function not found, downloading ..."
                                curl https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bash-aliases-functions.txt >> "$TMP_FILE"
                        else
                                cat ./bash-files/bash-aliases-functions.txt >> "$TMP_FILE"
                        fi
                        echo "Updating bash-me"
                        differences=$(diff "${HOME}"/.bash-me "$TMP_FILE")
                        if [ ${#differences} -ne 0 ]; then
                                read -p "this will erase the current file, are you sure you want to continue? y/n: " -n 1 -r
                                if [[ $REPLY =~ ^[Yy]$ ]]; then
                                        echo "Backup old file"
                                        mv "${HOME}"/.bash-me{,.old}
                                        echo "Updating bash-me with new version"
                                        cat "$TMP_FILE" >> "${HOME}"/.bash-me
                                else
                                        echo "Aborted"
                                fi
                        else
                                echo "No changes on file, nothing to update."
                        fi
                        if bash_check; then
                                echo "bash-me already in .bashrc"
                                echo "No changes needed"
                        else
                                echo "bash-me not found in .bashrc"
                                echo "Configuring ..."
                                echo "if [ -f ~/.bash-me ]; then" >>~/.bashrc
                                echo "    source ~/.bash-me" >>~/.bashrc
                                echo "fi" >>~/.bashrc
                                # shellcheck source=/dev/null
                                source ~/.bashrc
                        fi
                        echo "All Done!!"
                fi
        fi
}

function setNewBashrc() {
        echo "Setting user .bashrc"
        WHO="$(whoami)"
        if [ "$WHO" != "root" ]; then
                echo "You're $WHO"
                if [ -f "${HOME}/.bashrc" ]; then
                        echo ".bashrc found!"
                        echo "Overwrite ~/.bashrc?"
                        read -p "this will erase the current file, are you sure you want to continue? y/n: " -n 1 -r
                        echo ""
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                                echo ""
                                echo "Backup old file"
                                mv "${HOME}"/.bashrc{,.orig}
                                echo "Updating .bashrc with new version"
                                cp ./bash-files/bashrc_debian "${HOME}/.bashrc"
                                source "${HOME}/.bashrc"
                                echo "Done!"
                        else
                                echo "Aborted"
                        fi
                else
                        echo ".bashrc NOT found!"
                        echo "Adding new .bashrc file"
                        cp ./bash-files/bashrc_debian "${HOME}/.bashrc"
                        source "${HOME}/.bashrc"
                        echo ""
                        echo "Done!"
                fi
        else
                echo "You're $WHO"
                if [ -f "${HOME}/.bashrc" ]; then
                        echo ".bashrc found!"
                        echo "Overwrite ~/.bashrc?"
                        read -p "this will erase the current file, are you sure you want to continue? y/n: " -n 1 -r
                        echo ""
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                                echo ""
                                echo "Backup old file"
                                mv "${HOME}"/.bashrc{,.orig}
                                echo "Updating .bashrc with new version"
                                if [ -d bash-files ]; then
                                        cp ./bash-files/bashrc_root "${HOME}/.bashrc"
                                        source "${HOME}/.bashrc"
                                        echo "Done!"
                                else
                                        echo ""
                                        echo "Downloading files"
                                        curl -O https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bashrc_root
                                        mv bashrc_root "${HOME}/.bashrc"
                                        source "${HOME}/.bashrc"
                                        echo "Done!"
                                fi
                        else
                                echo "Aborted"
                        fi
                else
                        echo ".bashrc NOT found!"
                        echo "Adding new .bashrc file"
                        if [ -d bash-files ]; then
                                cp ./bash-files/bashrc_root "${HOME}/.bashrc"
                                echo "Done!"
                        else
                                echo ""
                                echo "Downloading files"
                                curl -O https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bashrc_root
                                mv bashrc_root "${HOME}/.bashrc"
                                source "${HOME}/.bashrc"
                                echo "Done!"
                        fi
                        echo "Done!"
                fi
        fi
}

function updateBashMe() {
        # update bash-me without questions
        if [ -f "${HOME}/.bash-me" ]; then
                echo ".bash-me found!"
                echo "Overwriting ~/.bash-me?"
                echo "Backing old file"
                mv "${HOME}"/.bash-me{,.old}
                echo "Updating bash-me with new version"
                if [ -d bash-files ]; then
                        cat ./bash-files/bash-aliases-extra.txt >>~/.bash-me
                        cat ./bash-files/bash-aliases-functions.txt >>~/.bash-me
                        echo "Done!"
                else
                        echo ""
                        echo "Downloading files"
                        echo "bash-files/bash-aliases-extra not found, downloading ..."
                        curl https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bash-aliases-extra.txt >>"$TMP_FILE"
                        echo ""
                        echo "bash-aliases-function not found, downloading ..."
                        curl https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bash-aliases-functions.txt >>"$TMP_FILE"
                        echo "Updating bash-me with new version"
                        cat "$TMP_FILE" >>"${HOME}"/.bash-me
                fi
        else
                echo ".bash-me NOT found!"
                echo "Installing unattended"
                echo ""
                echo "Downloading files"
                echo "bash-files/bash-aliases-extra not found, downloading ..."
                curl https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bash-aliases-extra.txt >>"$TMP_FILE"
                echo ""
                echo "bash-aliases-function not found, downloading ..."
                curl https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bash-aliases-functions.txt >>"$TMP_FILE"
                echo "Updating bash-me with new version"
                cat "$TMP_FILE" >>"${HOME}"/.bash-me
        fi

}

# case commands: bash-me, bash-u, bash-r
case $COMMAND in
bashme | me)
        echo 
        echo "Installing BashMe aliases"
        dumpBashMeFiles
        echo 
        ;;
bashrc | rc)
        echo
        echo "Updating .bashrc file"
        setNewBashrc
        echo
        ;;
update | u)
        echo
        echo "update bashMe"
        updateBashMe
        echo
        ;;
*)
        echo "Fail"
        ;;

esac
shift
