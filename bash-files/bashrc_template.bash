# ~/.bashrc_template.bash: Unified bashrc for all users
# Combines best features from bashrc_debian and bashrc_root

# Set HOME and ENV for root
if [ "$(whoami)" = "root" ]; then
    HOME="/root"
    ENV="$HOME/.bashrc"
    export ENV
fi

export SHELL=/bin/bash

# History settings
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=50000
export HISTFILESIZE=10000
shopt -s histappend
PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND "

# Window size check
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

if [ -n "$PS1" ] && [ "$(whoami)" = "root" ]; then
    PS1="\[\033[01;31m\]\u@\h \[\033[01;34m\]\w $ \[\033[00m\]";
else
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

export TERM=xterm-color

# PATH and MANPATH
export PATH="/usr/local/bin:/sbin:/bin:/usr/bin:/usr/sbin:/opt/X11/bin:/usr/libexec:$HOME/bin:$PATH"
export MANPATH=/opt/local/share/man:$MANPATH
umask 022


# Enable color support of ls and add handy aliases
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias ll='ls -lhaGs --color=auto'
    alias l.='ls -d .* --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# More ls aliases
alias la='ls -A'
alias l='ls -lGh'

# Quick cd aliases
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'

# Make mount command output pretty and human readable format
alias mount='mount |column -t'

# Some helps
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias vi=vim
alias wget='wget -c'

# Stop after sending count ECHO_REQUEST packets
alias ping='ping -c 5'
# Ports scanning
alias ports='sudo netstat -tulanp'

# Personal aliases
alias pid='ps aux -ww|cut -d : -f 2'
alias la='ls -latrhsGC'
alias dir='ls -lGC'
alias die='killall ssh'
alias copy='rsync -avzPh'

hist() { history |grep "$@"; }

# Alias definitions from ~/.bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable programmable completion features
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Enable bash-me file
if [ -f ~/.bash-me ]; then
    . ~/.bash-me
fi
