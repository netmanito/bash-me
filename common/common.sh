#!/bin/bash

log() {
    LEVEL=$1
    shift
    MESSAGE=$@

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
# Print help message
function help() {
    log INFO "📘 Help"
    log INFO ""
    log INFO "🛠️ Option: bashme, m"
    log INFO "Install or update BashMe aliases and functions"
    log INFO ""
    log INFO "📂 Option: bashrc, b"
    log INFO "Install new bashrc file"
    log INFO ""
    log INFO "❌ Option: uninstall, u"
    log INFO "Remove .bash-me file"
    log INFO "Remove references in .bashrc"
    log INFO ""
}

# Check if bash-me was previously installed
findBashMe() {
        find ~/ -iname .bash-me
}

# Download or use a file (aliases or functions)
downloadOrUseFile() {
    local FILE_NAME=$1
    local DESCRIPTION=$2

    if [ ! -f "bash-files/$FILE_NAME" ]; then
        log WARN "bash-files/$FILE_NAME not found, downloading ..."
        log INFO "Downloading $DESCRIPTION"
        if ! curl -f -o "$TMP_FILE" "https://raw.githubusercontent.com/netmanito/bash-me/$BRANCH/bash-files/$FILE_NAME"; then
            log ERROR "Failed to download $FILE_NAME"
            return 1
        fi
    else
        log INFO "Appending $DESCRIPTION to ~/.bash-me"
        cat "bash-files/$FILE_NAME" >>~/.bash-me
        log INFO "Bash-me file created"
    fi
}

# ! DEPRECATING - new downloadOrUseFile function replaces this
# don't remove until all functions are updated
# Download and install bash aliases and functions
downloadOrUseAliasesExtra() {
        if [ ! -f bash-files/bash-aliases-extra.txt ]; then
                echo "bash-files/bash-aliases-extra not found, downloading ..."
                echo "Downloading bash aliases extra"
                curl https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bash-aliases-extra.txt >>"$TMP_FILE"
        else
                echo "..."
                echo "# bash-me extra functionalities" >~/.bash-me
                cat ./bash-files/bash-aliases-extra.txt >>~/.bash-me
        fi
}

downloadOrUseFunctionsExtra() {
        if [ ! -f bash-files/bash-aliases-functions.txt ]; then
                echo "bash-files/bash-aliases-functions not found, downloading ..."
                echo "Downloading bash aliases functions"
                curl https://raw.githubusercontent.com/netmanito/bash-me/"$BRANCH"/bash-files/bash-aliases-functions.txt >>"$TMP_FILE"
        else
                echo "updating bash-me"
                cat ./bash-files/bash-aliases-functions.txt >>~/.bash-me
        fi
}