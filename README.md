# Bash Me

Bash Me AKA bash-me is a set of aliases and functions useful for my daily work.

Some aliases and functions for bash

## Install 

Run:

```
$ curl -sL https://raw.githubusercontent.com/netmanito/bash-me/main/bash-me.sh | bash -

$ curl -sL https://raw.githubusercontent.com/netmanito/bash-me/bashrcs/bash-me.sh | bash -s me
```

Or download the repository and the run the `bash-me.sh` script.

```
$ git clone https://github.com/netmanito/bash-me.git
$ cd bash-me
$ ./bash-me.sh me
```

### Options

* **me** Creates `~/.bash-me` with alias and functions and adds path on `~/.bashrc`.
* **rc | bashrc** adds a new `~/.bashrc` file for the current user.
* **up | update** updates  `~/.bash-me` with no questions.

## Configure

A new file `.bash-me` file will be created in your home directory.

`.bashrc` will be modified to include `.bash-me` at the end of the file

```
if [ -f ~/.bash-me ]; then
    source ~/.bash-me
fi
```
## TODO

* bash-me | me 'create and update' works fine (/)
* bash-me | rc 'install new .bashrc' - review (x)
* bash-me | destroy 'uninstall bash-me' - todo (x)