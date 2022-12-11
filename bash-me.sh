#!/bin/bash

findBashMe() {
        find ~/ -name .bash_me
}

ALIASES=$(findBashMe)

BASH_ME=$(
        cat <<EOF >>~/.bashrc
   if [ -f ~/.bash_me ]; then
        source ~/.bash_me
   fi
EOF
)

if [ -z "$ALIASES" ]; then
        echo "Downloading bash aliases extra"
        curl -O https://raw.githubusercontent.com/netmanito/repo/master/bash-aliases-extra
        curl -O https://raw.githubusercontent.com/netmanito/repo/master/bash-aliases-functions
        echo "no .bash_me found, creating it for you"
        read -r -p "Press ENTER to continue"
        echo "..."
        echo "# bash_me extra functionalities" >> ~/.bash_me
        cat ./bash-aliases-extra >> ~/.bash_me
        echo "updating shell"
        cat ./bash-aliases-functions >> ~/.bash_me
        echo "adding bash_me to .bashrc"
        $BASH_ME
        echo "removing process files"
        # rm $HOME/bash-aliases-{extra,functions}
        echo "All Done!!"
else
        echo ".bash_me found on your home directory"
        echo "Do you want to update?"
        read -p "Press ENTER to continue"
        echo "Downloading bash aliases extra"
        # curl -O https://raw.githubusercontent.com/netmanito/repo/master/bash-aliases-extra
        # curl -O https://raw.githubusercontent.com/netmanito/repo/master/bash-aliases-functions
        echo "Updating bash-me"
        read -p "this will erase the current file, are you sure you want to continue?"
        echo "# bash aliases extra" >> ~/.bash_me
        cat ./bash-aliases-extra >> ~/.bash_me
        cat ./bash-aliases-functions >> ~/.bash_me
        echo "updating shell"
        # rm $HOME/bash-aliases-{extra,functions}
        echo "All Done!!"
fi

echo "sourcing bashrc"
source ${HOME}/.bashrc
