#!/bin/bash
source ./common/common.sh

## Star of bash-me.sh

# Check if bash-me was previously installed
ALIASES=$(findBashMe)

# Function to update bash-me
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

# Function to deploy bash-me and add it to .bashrc
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
            echo "Reload your .bashrc"
            # shellcheck source=/dev/null
            echo "Run: source ~/.bashrc"
            echo "or restart your terminal"
            echo "All Done!!"
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

# Function to remove bash-me from .bashrc
destroyBashMe() {
    echo "Deleting bash-me"
    if [ -f "${HOME}/.bash-me" ]; then
        echo "Deleting .bash-me"
        rm "${HOME}/.bash-me"
    else
        echo ".bash-me not found"
    fi
    if bash_check; then
        echo "Removing bash-me from .bashrc"
        sed -i '/bash-me/,+2d' "${HOME}"/.bashrc
    else
        echo "No changes needed on .bashrc"
    fi
}

## End of bash-me.sh

# This script is used to set up a new .bashrc file for the user.
# It checks if the user is root or not and handles the .bashrc file accordingly.
# It also provides an option to back up the existing .bashrc file before overwriting it.
function setNewBashrc() {
    echo "Setting up user .bashrc"
    local WHO="$(whoami)"
    local BASHRC_FILE="${HOME}/.bashrc"
    local BACKUP_FILE="${BASHRC_FILE}.orig"
    local NEW_BASHRC_FILE

    # Determine the appropriate bashrc file based on user
    if [ "$WHO" == "root" ]; then
        NEW_BASHRC_FILE="bashrc_root"
    else
        NEW_BASHRC_FILE="bashrc_debian"
    fi

    # Check if .bashrc exists
    if [ -f "$BASHRC_FILE" ]; then
        echo ".bashrc found!"
        read -p "Overwrite ~/.bashrc? This will change the current file. Are you sure? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            return
        fi

        # Backup the existing .bashrc
        echo "Backing up the current .bashrc to $BACKUP_FILE"
        if ! cp "$BASHRC_FILE" "$BACKUP_FILE"; then
            echo "Error: Failed to back up .bashrc" >&2
            return 1
        fi
    else
        echo ".bashrc not found. A new one will be created."
    fi

    # Update or download the new .bashrc
    if [ -d bash-files ]; then
        echo "Using local bash-files directory."
        if ! cp "./bash-files/$NEW_BASHRC_FILE" "$BASHRC_FILE"; then
            echo "Error: Failed to copy $NEW_BASHRC_FILE to $BASHRC_FILE" >&2
            return 1
        fi
    else
        echo "Local bash-files directory not found. Downloading $NEW_BASHRC_FILE..."
        if ! curl -f -O "https://raw.githubusercontent.com/netmanito/bash-me/$BRANCH/bash-files/$NEW_BASHRC_FILE"; then
            echo "Error: Failed to download $NEW_BASHRC_FILE" >&2
            return 1
        fi
        mv "$NEW_BASHRC_FILE" "$BASHRC_FILE"
    fi

    # Source the new .bashrc
    echo "Sourcing the new .bashrc..."
    if ! source "$BASHRC_FILE"; then
        echo "Error: Failed to source $BASHRC_FILE" >&2
        return 1
    fi

    echo "Done! Your .bashrc has been updated."
}
