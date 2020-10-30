function prepend_to_path_if_exists () {
    if [ -d "$1" ]; then
        case ":$PATH:" in
            *":$1:"*) :;; # Already exists
            *) export PATH="$1:$PATH";;
        esac
    fi
}

function source_if_exists () {
    if [ -f $1 ]; then
        source "$1"
    fi
}

function interactive_shell () {
    [[ $- == *i* ]];
}

function mkcd () {
    mkdir -p $1 && cd $1;
}

# Put /usr/local ahead of /usr to give priority to Homebrew/customized apps
prepend_to_path_if_exists /usr/local/bin
prepend_to_path_if_exists /usr/local/sbin
prepend_to_path_if_exists /usr/local/netbin
prepend_to_path_if_exists /local/bin
prepend_to_path_if_exists $HOME/bin

export HISTFILE="$HOME/.bash_history.$(hostname -s)"
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000

# _Really_ use English and UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export TZ="America/New_York"

export EDITOR="vim"
export VISUAL="vim"

# Don't redirect output on top of existing files
set -o noclobber

# Case-insensitive filename expansion
shopt -s nocaseglob

# Enable START/STOP output control
if interactive_shell; then
    stty -ixon
fi

source_if_exists $HOME/.bash_aliases

# Autojump
if [ -f /usr/share/autojump/autojump.bash ] || [ -f /usr/local/etc/autojump.sh ]; then
    export AUTOJUMP_KEEP_SYMLINKS=1
    export AUTOJUMP_AUTOCOMPLETE_CMDS='code cp mv vim'

    if [ -f /usr/share/autojump/autojump.bash ]; then
        source /usr/share/autojump/autojump.bash
    else
        source /usr/local/etc/autojump.sh
    fi
fi

# Docker & Docker Compose
prepend_to_path_if_exists /opt/docker/bin
export DOCKER_COMPOSE_USER_ID=$(id -u)

# Git
prepend_to_path_if_exists /usr/local/opt/git/libexec/git-core
source_if_exists /usr/local/etc/bash_completion.d/git-completion.bash
source_if_exists /usr/local/etc/bash_completion.d/git-prompt.sh

# Java
if [ -f /usr/libexec/java_home ]; then
    export JAVA_HOME=$(/usr/libexec/java_home)
fi

# MathWorks
export LOCATION=AH

# Node/NPM
prepend_to_path_if_exists /usr/local/share/npm/bin
source_if_exists /usr/local/etc/bash_completion.d/npm

# Visual Studio Code (Have to set $EDITOR before configuring Perforce)
prepend_to_path_if_exists "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
if type code &>/dev/null; then
    export EDITOR="code --wait"
    export VISUAL="code --wait"
fi

# OpenSSL (via Homebrew)
if type brew &>/dev/null; then
    if [ -d $(brew --prefix openssl) ]; then
        export LIBRARY_PATH=$LIBRARY_PATH:"$(brew --prefix openssl)/lib/"
    fi
fi

# rbenv
if type rbenv &>/dev/null; then
    eval "$(rbenv init -)"
fi

# Ruby
if [ -d /opt/ruby/bin ]; then
    export PATH=/opt/ruby/bin:$PATH
    export GEM_SPEC_CACHE=/opt/ruby/gems/spec_cache
    export BUNDLE_PATH=/opt/ruby/gems
fi

# Do this almost-last to allow host-specific overrides
source_if_exists "$HOME/.bashrc.$(hostname -s)"

# Do this next-to-last to pick up host-specific overrides
if [ $(uname) == "Darwin" ]; then
    source_if_exists "$HOME/.bash_prompt"
else
    export PS1="\n[\h] \$(pwd)\n$ "
fi

# Do this last-last to ensure that `history` is at the end
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;} history -a"
