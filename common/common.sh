#!/bin/bash

# Check if bash-me was previously installed
findBashMe() {
        find ~/ -iname .bash-me
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