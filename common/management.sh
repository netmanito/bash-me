#!/bin/bash
source <(curl -s https://raw.githubusercontent.com/netmanito/bash-me/refs/heads/bashrcs/common/common.sh)

## Star of bash-me.sh

# Check if bash-me was previously installed
ALIASES=$(findBashMe)

# Function to update bash-me
function bashMeUpdate() {
    log INFO "Updating BashMe"
    downloadOrUseFile "bash-aliases-extra.bash" "bash aliases extra"
    downloadOrUseFile "bash-aliases-functions.bash" "bash aliases functions"
    differences=$(diff "${HOME}"/.bash-me "$TMP_FILE")
    if [ ${#differences} -ne 0 ]; then
        read -p "This will erase the current configuration. Are you sure? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log INFO "Backing up old .bash-me file"
            mv "${HOME}"/.bash-me{,.old}
            log INFO "Updating .bash-me with the new version"
            cat "$TMP_FILE" >>"${HOME}"/.bash-me
        else
            log WARN "Update aborted by user"
        fi
    else
        log INFO "No changes detected in .bash-me"
    fi
    if bash_check; then
        log INFO "bash-me already configured in .bashrc"
    else
        log INFO "Adding bash-me to .bashrc"
        addBashMe
    fi
    log INFO "All Done!"
}

# Function to deploy bash-me and add it to .bashrc
function deployBashMe() {
    if [ -z "$ALIASES" ]; then
        log INFO "📂 No .bash-me found, creating it for you"
        downloadOrUseFile "bash-aliases-extra.bash" "bash aliases extra"
        downloadOrUseFile "bash-aliases-functions.bash" "bash aliases functions"
        log INFO "⚙️ Adding BashMe to .bashrc"
        read -p "Press Enter to confirm, or any other key to exit: " -n 1 -r
        echo
        if [[ ! $REPLY == "" ]]; then
            log WARN "🚫 Operation aborted by user"
            exit 1
        fi
        addBashMe
        log INFO "✅ BashMe added to .bashrc." 
        log INFO "🔄 Reload your .bashrc or restart your terminal."
    else
        log INFO "📁 .bash-me found in your home directory"
        read -p "❓ Do you want to update? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            bashMeUpdate
        else
            log WARN "🚫 Update aborted by user"
        fi
    fi
}

# Function to add bash-me to .bashrc
addBashMe() {
    log INFO "🔍 bash-me not found in .bashrc"
    log INFO "⚙️ Configuring bash-me in .bashrc..."
    {
        echo "if [ -f ~/.bash-me ]; then"
        echo "    source ~/.bash-me"
        echo "fi"
    } >>~/.bashrc
    log INFO "✅ bash-me successfully added to .bashrc"
}

# Function to remove bash-me from .bashrc
destroyBashMe() {
    log INFO "🗑️ Deleting BashMe"
    if [ -f "${HOME}/.bash-me" ]; then
        log INFO "🗂️ Deleting .bash-me file"
        rm "${HOME}/.bash-me"
    else
        log WARN "⚠️ .bash-me file not found"
    fi
    if bash_check; then
        log INFO "📝 Removing bash-me from .bashrc"
        sed -i '/bash-me/,+2d' "${HOME}"/.bashrc
    else
        log INFO "✅ No changes needed in .bashrc"
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
        log INFO "📄 .bashrc found!"
        read -p "❓ Overwrite ~/.bashrc? This will change the current file. Are you sure? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log WARN "🚫 Aborted by user."
            return
        fi

        # Backup the existing .bashrc
        log INFO "🗂️ Backing up the current .bashrc to $BACKUP_FILE"
        if ! cp "$BASHRC_FILE" "$BACKUP_FILE"; then
            log ERROR "❌ Failed to back up .bashrc"
            return 1
        fi
    else
        log INFO "📄 .bashrc not found. A new one will be created."
    fi

    # Update or download the new .bashrc
    if [ -d bash-files ]; then
        log INFO "📂 Using local bash-files directory."
        if ! cp "./bash-files/$NEW_BASHRC_FILE" "$BASHRC_FILE"; then
            log ERROR "❌ Failed to copy $NEW_BASHRC_FILE to $BASHRC_FILE"
            return 1
        fi
    else
        log WARN "⚠️ Local bash-files directory not found. Downloading $NEW_BASHRC_FILE..."
        if ! curl -f -O "https://raw.githubusercontent.com/netmanito/bash-me/$BRANCH/bash-files/$NEW_BASHRC_FILE"; then
            log ERROR "❌ Failed to download $NEW_BASHRC_FILE"
            return 1
        fi
        mv "$NEW_BASHRC_FILE" "$BASHRC_FILE"
    fi

    # Source the new .bashrc
    log INFO "🔄 Sourcing the new .bashrc..."
    if ! source "$BASHRC_FILE"; then
        log ERROR "❌ Failed to source $BASHRC_FILE"
        return 1
    fi

    log INFO "✅ Done! Your .bashrc has been updated."
}
