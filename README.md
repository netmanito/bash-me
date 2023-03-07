# Bash Me

Bash Me AKA bash-me is a set of aliases and functions useful for my daily work.

Some aliases and functions for bash



## Install 

Run:
```
$ curl -sL https://raw.githubusercontent.com/netmanito/bash-me/main/bash-me.sh | bash -

$ curl -sL https://raw.githubusercontent.com/netmanito/bash-me/bashrcs/bash-me.sh | bash -s up

```

Or download the repository and the run the `bash-me.sh` script.

```
$ git clone https://github.com/netmanito/bash-me.git
$ cd bash-me
$ ./bash-me.sh me
```

### Options

* **me** adds bash aliases and functions in `~/.bashrc` file and adds path on `~/.bashrc`.
* **u | user** adds a `~/.bashrc` for the current user.
* **up | update** adds a `~/.bashrc` with no questions.
## Configure

A new file .bash-me will be created in your home directory 

`.bashrc` will be modified to include `.bash-me` at the end of the file

```
if [ -f ~/.bash-me ]; then
    source ~/.bash-me
fi
```
## TODO

* Make new options to work from remote url. ❌
* Default option looks equal to user option, maybe remove it. ✅
* rename bashrc files to txt for let tmp file when installing from remote. ✅
* rename bash_me to bash-me ✅

## Debian set

```
$ apt-get install vim vim-scripts screen mc rsync git build-essential zip links arj fdupes apt-file lsof strace htop locate curl
```