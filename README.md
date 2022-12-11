# Bash Me

Bash Me AKA bash_me is a set of aliases and functions useful for my daily work.

Some aliases and functions for bash



## Install 

Run:
```
curl -sL https://raw.githubusercontent.com/netmanito/repo/master/bash-me.sh | bash -
```

## Configure

A new file .bash_me will be created in your home directory 

`.bashrc` will be modified to include `.bash_me` at the end of the file

```
if [ -f ~/.bash_me ]; then
    source ~/.bash_me
fi
```


