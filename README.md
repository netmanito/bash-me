# Bash Me

Bash Me AKA bash-me is a set of aliases and functions useful for my daily work.

Some aliases and functions for bash



## Install 

Run:
```
curl -sL https://raw.githubusercontent.com/netmanito/bash-me/main/bash-me.sh | bash -

curl -sL https://raw.githubusercontent.com/netmanito/bash-me/bashrcs/bash-me.sh | bash -s -- me

```

Or download the repository and the run the `bash-me.sh` script.

## Configure

A new file .bash-me will be created in your home directory 

`.bashrc` will be modified to include `.bash-me` at the end of the file

```
if [ -f ~/.bash-me ]; then
    source ~/.bash-me
fi
```
## TODO

* Make new options to work from remote url.