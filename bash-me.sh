#!/bin/bash

# Check if bash_me was previously installed
findBashMe() {
  find ~/ -iname .bash_me
}

ALIASES=$(findBashMe)

# Check if bash_me is configured in .bashrc
bash_check() {
  grep -q bash_me "${HOME}"/.bashrc
  return $?
}

# Install procedure
if [ -z "$ALIASES" ]; then
        # Check if working from repository or remote execution
        echo "Checking required files"
        if [ ! -f bash-aliases-extra ]; then
                echo "bash-aliases-extra not found, downloading ..."
                echo "Downloading bash aliases extra"
                curl -O https://raw.githubusercontent.com/netmanito/bash-me/main/bash-aliases-extra
        fi
        if [ ! -f bash-aliases-functions ]; then
                echo "bash-aliases-functions not found, downloading ..."
                echo "Downloading bash aliases functions"
                curl -O https://raw.githubusercontent.com/netmanito/bash-me/main/bash-aliases-functions
        fi
        echo "no .bash_me found, creating it for you"
        read -r -p "Press ENTER to continue"
        echo "..."
        echo "# bash_me extra functionalities" > ~/.bash_me
        cat ./bash-aliases-extra >> ~/.bash_me
        echo "updating bash_me"
        cat ./bash-aliases-functions >> ~/.bash_me
        echo "adding bash_me to .bashrc"
        bash_check
        if [ $? -eq 0 ]; then
           echo "bash_me already in .bashrc"
           echo "No changes needed"
        else
           echo "bash_me not found in .bashrc"
           echo "Configuring ..."
           echo "if [ -f ~/.bash_me ]; then" >> ~/.bashrc
           echo "    source ~/.bash_me" >> ~/.bashrc
           echo "fi" >> ~/.bashrc
        fi
        echo "removing process files"
        if [ "${PWD}" == "${HOME}" ]; then
                rm "$HOME"/bash-aliases-{extra,functions}
        fi
        echo "All Done!!"
else
        echo ".bash_me found on your home directory"
        echo "Do you want to update?"
        read -p "y/n: " -n 1 -r
        echo   
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
        # Check if files are already downloaded
        if [ ! -f bash-aliases-extra ]; then
            echo "bash-aliases-extra not found, downloading ..."
            curl -O https://raw.githubusercontent.com/netmanito/bash-me/main/bash-aliases-extra
        fi
        if [ ! -f bash-aliases-functions ]; then
            echo "bash-aliases-function not found, downloading ..."
            curl -O https://raw.githubusercontent.com/netmanito/bash-me/main/bash-aliases-functions
        fi
        echo "Updating"
        cat ./bash-aliases-extra >>~/.bash_me
        cat ./bash-aliases-functions >>~/.bash_me
        echo "updating shell"
        if [ "${PWD}" == "${HOME}" ]; then
                rm "$HOME"/bash-aliases-{extra,functions}
        fi
        echo "All Done!!"
        fi
fi
