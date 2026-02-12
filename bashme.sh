#!/bin/bash

# Common functions and logging
log() {
    local LEVEL=$1
    shift
    local MESSAGE=$@

    if [[ $SILENT -eq 1 ]] && [[ $SHOW_ERRORS -eq 0 || $LEVEL != "ERROR" ]]; then
        return 0
    fi

    case $LEVEL in
        ERROR)
            LEVEL="\e[91mERROR\e[0m"
            ;;
        INFO)
            LEVEL=" \e[92mINFO\e[0m"
            ;;
        WARN)
            LEVEL=" \e[93mWARN\e[0m"
            ;;
        *)
            ;;
    esac

    printf "%s | $LEVEL : %b\n" "$(date)" "$MESSAGE"
}

# Help function
help() {
    log INFO "📘 Help"
    log INFO ""
    log INFO "🛠️ Option: install, i"
    log INFO "Install or update BashMe aliases and functions"
    log INFO ""
    log INFO "📂 Option: bash, b"
    log INFO "Install new bashrc file"
    log INFO ""
    log INFO "❌ Option: uninstall, u"
    log INFO "Remove .bash-me file"
    log INFO "Remove references in .bashrc"
    log INFO ""
}

# Management functions for bash-me
TMP_FILE=$(mktemp -q "${PWD}"/bash-me.XXXXXX)
# trap 'rm -f $TMP_FILE' 0 2 3 15
trap on_exit SIGHUP SIGINT SIGTERM SIGQUIT EXIT

on_exit() {
    rm -f "$TMP_FILE"
}

findBashMe() {
    find ~ -maxdepth 4 -iname .bash-me
}

bash_check() {
    grep -q bash-me "${HOME}"/.bashrc
    return $?
}

check_and_download_file() {
    local FILE_NAME=$1
    local DESCRIPTION=$2

    if [ ! -f "bash-files/$FILE_NAME" ]; then
        log WARN "$DESCRIPTION not found, downloading..."
        if ! curl -f "https://raw.githubusercontent.com/netmanito/bash-me/$BRANCH/bash-files/$FILE_NAME" -o "$TMP_FILE"; then
            log ERROR "Failed to download $DESCRIPTION"
            return 1
        fi
    else
        log INFO "Appending $DESCRIPTION to ~/.bash-me"
        cat "bash-files/$FILE_NAME" >>~/.bash-me
        log INFO "Bash-me file created"
    fi
}

function bashMeUpdate() {
    log INFO "Updating BashMe"
    check_and_download_file "bash-aliases-extra.bash" "bash aliases extra"
    check_and_download_file "bash-aliases-functions.bash" "bash aliases functions"
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
        addBashMe
    fi
    log INFO "All Done!"
}

function deployBashMe() {
    if [ -z "$ALIASES" ]; then
        log INFO "📂 No .bash-me found, creating it for you"
        read -p "Press Enter to confirm, or any other key to exit: " -n 1 -r
        echo
        if [[ ! $REPLY == "" ]]; then
            log WARN "🚫 Operation aborted by user"
            exit 1
        fi
        check_and_download_file "bash-aliases-extra.bash" "bash aliases extra"
        check_and_download_file "bash-aliases-functions.bash" "bash aliases functions"
        
        if bash_check; then
            log INFO "bash-me already configured in .bashrc"
        else
            addBashMe
            log INFO "✅ BashMe added to .bashrc." 
            log INFO "🔄 Reload your .bashrc or restart your terminal."
        fi
        log INFO "🎉 All Done!"
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

function addBashMe() {
    log INFO "🔍 bash-me not found in .bashrc"
    log INFO "⚙️ Configuring bash-me in .bashrc..."
    if ! grep -q 'source ~/.bash-me' "${HOME}"/.bashrc; then
        echo "if [ -f ~/.bash-me ]; then" >>~/.bashrc
        echo "    source ~/.bash-me" >>~/.bashrc
        echo "fi" >>~/.bashrc
        log INFO "✅ bash-me successfully added to .bashrc"
    else
        log INFO "✅ bash-me already configured in .bashrc"
    fi
}

function destroyBashMe() {
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
        log INFO "✅ bash-me references removed from .bashrc"
    else
        log INFO "✅ No changes needed in .bashrc"
    fi
}

function setNewBashrc() {
    log INFO "Setting up user .bashrc"
    local BASHRC_FILE="${HOME}/.bashrc"
    local BACKUP_FILE="${BASHRC_FILE}.orig"
    local NEW_BASHRC_FILE="bashrc_template.bash"

    if [ -f "$BASHRC_FILE" ]; then
        log INFO "📄 .bashrc found!"
        read -p "❓ Overwrite ~/.bashrc? This will change the current file. Are you sure? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log WARN "🚫 Aborted by user."
            return
        fi

        log INFO "🗂️ Backing up the current .bashrc to $BACKUP_FILE"
        cp "$BASHRC_FILE" "$BACKUP_FILE"
    else
        log INFO "📄 .bashrc not found. A new one will be created."
    fi

    if [ -d bash-files ]; then
        log INFO "📂 Using local bash-files directory."
        cp "./bash-files/$NEW_BASHRC_FILE" "$BASHRC_FILE"
    else
        log WARN "⚠️ Local bash-files directory not found. Downloading $NEW_BASHRC_FILE..."
        if ! curl -f "https://raw.githubusercontent.com/netmanito/bash-me/$BRANCH/bash-files/$NEW_BASHRC_FILE" -o "$BASHRC_FILE"; then
            log ERROR "❌ Failed to download $NEW_BASHRC_FILE"
            return 1
        fi
    fi

    log INFO "✅ Done! Your .bashrc has been updated."
}

# exit on error
set -e

# Check correct parameters
USAGE="Usage: $0 <option install,i | uninstall,u | bash,b | help,h>"
EXPECTED=1
INTRO=$#
EXAMPLE="Example: $0 me"

if [[ $INTRO -lt $EXPECTED ]]; then
    log ERROR "Too few arguments. ❌"
    log INFO "$USAGE"
    log INFO "$EXAMPLE"
    exit 1
fi

# variables to work in requests
BRANCH="bashrcs"
COMMAND=$1
ALIASES=$(findBashMe)

case $COMMAND in
install | i)
    log INFO "Installing BashMe aliases"
    deployBashMe
    ;;
bash | b)
    log INFO "Updating .bashrc file"
    setNewBashrc
    ;;
uninstall | u)
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
