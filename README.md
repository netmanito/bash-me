Some aliases and functions for bash

A new file .bash_me will be created 

`.bashrc` will be modified to include .bash_me

if [ -f ~/.bash_me ]; then
    source ~/.bash_me
fi

Run:

```
curl -sL https://raw.githubusercontent.com/netmanito/repo/master/bash-me.sh | bash -
```

