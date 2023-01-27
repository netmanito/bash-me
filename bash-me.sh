#!/bin/bash

USAGE="Usage: $0 <option me | user,u | root,r | default,d >"
EXAMPLE="Example: $0 me"

if [[ "$#" -lt 1 ]]; then
        echo "ERROR" "Too few arguments. ❌"
        echo ""
        echo "$USAGE"
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

# Create temp file for new bash-me
# now make a temp file
TMP_FILE=$(mktemp -q /tmp/bash-me.XXXXXX)
trap "rm -f $TMP_FILE" 0 2 3 15

## variables to work in requests
COMMAND=$1

# case commands: bash-me, bash-u, bash-r
case $COMMAND in
bash-me | me)
        # Install procedure
        if [ -z "$ALIASES" ]; then
                # Check if working from repository or remote execution
                echo "Checking required files"
                if [ ! -f bash-files/bash-aliases-extra ]; then
                        echo "bash-files/bash-aliases-extra not found, downloading ..."
                        echo "Downloading bash aliases extra"
                        curl -O https://raw.githubusercontent.com/netmanito/bash-me/main/bash-files/bash-aliases-extra >>"$TMP_FILE"
                else 
                        echo "..."
                        echo "# bash-me extra functionalities" >~/.bash-me
                        cat ./bash-files/bash-aliases-extra >>~/.bash-me
                fi
                if [ ! -f bash-files/bash-aliases-functions ]; then
                        echo "bash-files/bash-aliases-functions not found, downloading ..."
                        echo "Downloading bash aliases functions"
                        curl -O https://raw.githubusercontent.com/netmanito/bash-me/main/bash-files/bash-aliases-functions >>"$TMP_FILE"
                else
                                        echo "updating bash-me"
                                        cat ./bash-files/bash-aliases-functions >>~/.bash-me
                fi
                echo "no .bash-me found, creating it for you"
                read -r -p "Press ENTER to continue"
                echo "..."
                echo "adding bash-me to .bashrc"
                bash_check
                if [ $? -eq 0 ]; then
                        echo "bash-me already in .bashrc"
                        echo "No changes needed"
                else
                        echo "bash-me not found in .bashrc"
                        echo "Configuring ..."
                        echo "if [ -f ~/.bash-me ]; then" >>~/.bashrc
                        echo "    source ~/.bash-me" >>~/.bashrc
                        echo "fi" >>~/.bashrc
                fi
                echo "removing process files"
                if [ "${PWD}" == "${HOME}" ]; then
                        rm "$HOME"/bash-aliases-{extra,functions}
                fi
                echo "All Done!!"
        else
                echo ".bash-me found on your home directory"
                echo "Do you want to update?"
                read -p "y/n: " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                        TMP_FILE=$(mktemp -q /tmp/bash-me.XXXXXX)
                        trap "rm -f $TMP_FILE" 0 2 3 15
                        # Check if files are already downloaded
                        if [ ! -f bash-files/bash-aliases-extra ]; then
                                echo "bash-files/bash-aliases-extra not found, downloading ..."
                                curl -O https://raw.githubusercontent.com/netmanito/bash-me/main/bash-files/bash-aliases-extra >>"$TMP_FILE"
                        fi
                        if [ ! -f bash-files/bash-aliases-functions ]; then
                                echo "bash-aliases-function not found, downloading ..."
                                curl -O https://raw.githubusercontent.com/netmanito/bash-me/main/bash-files/bash-aliases-functions >>"$TMP_FILE"
                        fi
                        echo "Updating bash-me"
                        #cat ./bash-files/bash-aliases-extra >>"$TMP_FILE"
                        #cat ./bash-files/bash-aliases-functions >>"$TMP_FILE"
                        differences=$(diff "${HOME}"/.bash-me "$TMP_FILE")
                        if [ ${#differences} -ne 0 ]; then
                                read -p "this will erase the current file, are you sure you want to continue? y/n: " -n 1 -r
                                if [[ $REPLY =~ ^[Yy]$ ]]; then
                                        echo "Backup old file"
                                        mv "${HOME}"/.bash-me{,.old}
                                        echo "Updating bash-me with new version"
                                        cat "$TMP_FILE" >>"${HOME}"/.bash-me
                                else
                                        echo "Aborted"
                                fi
                        else
                                echo "No changes on file, nothing to update."
                        fi
                        echo "updating shell"
                        if [ "${PWD}" == "${HOME}" ]; then
                                rm "$HOME"/bash-aliases-{extra,functions}
                        fi
                        echo "All Done!!"
                fi
        fi
        ;;
bash-u | u)
        echo "Setting user .bashrc"
        WHO="$(whoami)"
        if [ "$WHO" != "root" ]; then
                echo "You're $WHO"
                if [ -f "${HOME}/.bashrc" ]; then
                        echo ".bashrc found!"
                        echo "Overwrite ~/.bashrc?"
                        read -p "this will erase the current file, are you sure you want to continue? y/n: " -n 1 -r
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                                echo "Backup old file"
                                mv "${HOME}"/.bashrc{,.old}
                                echo "Updating .bashrc with new version"
                                cp ./bash-files/bashrc_debian "${HOME}/.bashrc"
                                echo "Done!"
                        else
                                echo "Aborted"
                        fi
                else
                        echo ".bashrc NOT found!"
                        echo "Adding new .bashrc file"
                        cp ./bash-files/bashrc_debian "${HOME}/.bashrc"
                        echo "Done!"
                fi
        else
                echo "You're root!"
                echo ""
                echo "Please use bash-me.sh root"
        fi
        ;;
bash-r | bash-root | root | r)
        echo "Setting root .bashrc"
        WHO="$(whoami)"
        if [ "$WHO" == "root" ]; then
                echo "You're $WHO"
                if [ -f "${HOME}/.bashrc" ]; then
                        echo ".bashrc found!"
                        echo "Overwrite ~/.bashrc?"
                        read -p "this will erase the current file, are you sure you want to continue? y/n: " -n 1 -r
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                                echo "Backup old file"
                                mv "${HOME}"/.bashrc{,.old}
                                echo "Updating .bashrc with new version"
                                cp ./bash-files/bashrc_root "${HOME}/.bashrc"
                                echo "Done!"
                        else
                                echo "Aborted"
                        fi
                else
                        echo ".bashrc NOT found!"
                        echo "Adding new .bashrc file"
                        cp ./bash-files/bashrc_root "${HOME}/.bashrc"
                        echo "Done!"
                fi
        else
                echo "You're not root!"
        fi
        ;;
default | d)
        if [ -f "${HOME}/.bashrc" ]; then
                echo ".bashrc found!"
                echo "Overwrite ~/.bashrc?"
                read -p "this will erase the current file, are you sure you want to continue? y/n: " -n 1 -r
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                        echo "Backup old file"
                        mv "${HOME}"/.bashrc{,.old}
                        echo "Updating .bashrc with new version"
                        cp ./bash-files/bashrc_debian "${HOME}/.bashrc"
                        echo "Done!"
                else
                        echo ""
                        echo "Aborted"
                fi
        else
                echo ".bashrc NOT found!"
                echo "Nothing to do."
        fi
        ;;
*)
        echo "Fail"
        ;;

esac
shift
