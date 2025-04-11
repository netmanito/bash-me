#!/bin/bash

# Help function
# Print help message
function help() {
        echo "Help"
        echo ""
        echo "Option: me"
        echo "Install BashMe aliases"
        echo ""
        echo "Option: rc"
        echo "Install new bashrc file"
        echo ""
        echo "Option: u"
        echo "Update bash-me file"
        echo ""
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
        echo "bash-files/$FILE_NAME not found, downloading ..."
        echo "Downloading $DESCRIPTION"
        if ! curl -f -o "$TMP_FILE" "https://raw.githubusercontent.com/netmanito/bash-me/$BRANCH/bash-files/$FILE_NAME"; then
            echo "Error: Failed to download $FILE_NAME" >&2
            return 1
        fi
    else
        echo "Appending $DESCRIPTION to ~/.bash-me"
        cat "bash-files/$FILE_NAME" >>~/.bash-me
    fi
}


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