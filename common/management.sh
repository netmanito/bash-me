#!/bin/bash
source ./common/common.sh

# Check if bash-me was previously installed
ALIASES=$(findBashMe)

function bashMeUpdate() {
    # Check if files are already downloaded
    downloadOrUseAliasesExtra
    downloadOrUseFunctionsExtra
    echo "Updating bash-me"
    differences=$(diff "${HOME}"/.bash-me "$TMP_FILE")
    if [ ${#differences} -ne 0 ]; then
        read -p "this will erase the current configuration, are you sure you want to continue? y/n: " -n 1 -r
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
}

# Function to dump bash-me files
function deployBashMe() {
    # Install procedure
    if [ -z "$ALIASES" ]; then
        # Check if working from repository or remote execution
        echo "Checking required files"
        downloadOrUseAliasesExtra
        downloadOrUseFunctionsExtra
        echo "no .bash-me found, creating it for you"
        read -r -p "Press ENTER to continue"
        echo "..."
        cat "$TMP_FILE" >>"${HOME}"/.bash-me
        echo "adding bash-me to .bashrc"
        if bash_check; then
            echo "bash-me already in .bashrc"
            echo "No changes needed"
        else
            addBashMe
            echo "BashMe added to .bashrc"
            echo "Reloading .bashrc"
            # shellcheck source=/dev/null
            source ~/.bashrc
            echo "Done!"
        fi
    else
        echo ".bash-me found on your home directory"
        echo "Do you want to update?"
        read -p "y/n: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            bashMeUpdate
        fi
    fi
}
# Function to add bash-me to .bashrc
addBashMe() {
    echo "bash-me not found in .bashrc"
    echo "Configuring ..."
    echo "if [ -f ~/.bash-me ]; then" >>~/.bashrc
    echo "    source ~/.bash-me" >>~/.bashrc
    echo "fi" >>~/.bashrc
}

# Function to update .bash-me
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

# This script is used to set up a new .bashrc file for the user.
# It checks if the user is root or not and handles the .bashrc file accordingly.
# It also provides an option to back up the existing .bashrc file before overwriting it.
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