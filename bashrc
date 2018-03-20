function prepend_to_path_if_exists () {
    if [ -d "$1" ]; then
        export PATH="$1":$PATH
    fi
}

function source_if_exists () {
    if [ -f $1 ]; then
        source "$1"
    fi
}

function mkcd () {
    mkdir -p $1 && cd $1;
}

function interactive_shell () {
    [[ $- == *i* ]];
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

# Save and reload the history after each command finishes
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"

# _Really_ use English and UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export TZ="America/New_York"

export EDITOR="vim"
export VISUAL="vim"

if [ $(uname) == "Darwin" ]; then
    export PS1="\n[$(hostname -s)] \$(pwd)\n "
else
    export PS1="\n[$(hostname -s)] \$(pwd)\n$ "
fi

# Don't redirect output on top of existing files
set -o noclobber

# Case-insensitive filename expansion
shopt -s nocaseglob

# Enable START/STOP output control.
if interactive_shell; then
    stty -ixon
fi

source_if_exists $HOME/.bash_aliases

# Ag
source_if_exists /usr/local/etc/bash_completion.d/ag.bashcomp.bash

# Atom
if type atom &>/dev/null; then
    export EDITOR="atom --wait"
    export VISUAL="atom --wait"
fi

# Autojump
if [ -f /usr/share/autojump/autojump.bash ] || [ -f /usr/local/etc/autojump.sh ]; then
    export AUTOJUMP_KEEP_SYMLINKS=1
    export AUTOJUMP_AUTOCOMPLETE_CMDS='atom cp mv vim'

    if [ -f /usr/share/autojump/autojump.bash ]; then
        source /usr/share/autojump/autojump.bash
    else
        source /usr/local/etc/autojump.sh
    fi
fi

# Docker Compose
prepend_to_path_if_exists /opt/docker/bin

# Git
prepend_to_path_if_exists /usr/local/opt/git/libexec/git-core
source_if_exists /usr/local/etc/bash_completion.d/git-completion.bash

# Java
if [ -f /usr/libexec/java_home ]; then
    export JAVA_HOME=$(/usr/libexec/java_home)
fi

# MathWorks
export LOCATION=AH

# Node/NPM
prepend_to_path_if_exists /usr/local/share/npm/bin
source_if_exists /usr/local/etc/bash_completion.d/npm

# Perforce
export P4CONFIG=.perforce
export P4EDITOR=$EDITOR
export P4IGNORE=.gitignore
export P4LOGINSSO=/hub/bat/share/p4admin.latest/sso/sso-client
export P4PORT=perforce:1666
export P4USER=rsouza

# rbenv
if [ -d /usr/local/rbenv ]; then
    export PATH=/usr/local/rbenv/bin:$PATH
    export RBENV_ROOT=/usr/local/rbenv

    eval "$(rbenv init -)"
fi

# Ruby
if [ -d /opt/ruby/bin ]; then
    export PATH=/opt/ruby/bin:$PATH
    export GEM_SPEC_CACHE=/opt/ruby/gems/spec_cache
    export BUNDLE_PATH=/opt/ruby/gems
fi

# Ruby development server
source_if_exists "/sandbox/$USER/mw-ruby-development-server/env.bash"

# Visual Studio Code
prepend_to_path_if_exists "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Do this last to allow host-specific overrides
source_if_exists "$HOME/.bashrc.$(hostname -s)"
