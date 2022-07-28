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

# Reset
export PROMPT_COMMAND=

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

# May be overwritten by .bash_prompt
export PS1="\n[\h] \$(pwd)\n$ "

export EDITOR="vim"
export VISUAL="vim"

# Don't redirect output on top of existing files
set -o noclobber

# Case-insensitive filename expansion
shopt -s nocaseglob

# Cache slow lookups
if type brew &>/dev/null; then
    __have_homebrew=1
    __openssl_brew_prefix=$(brew --prefix openssl)
fi

# Enable START/STOP output control
if interactive_shell; then
    stty -ixon
fi

source_if_exists $HOME/.bash_aliases

# asdf
if [ $__have_homebrew ]; then
    source_if_exists "$(brew --prefix asdf)/libexec/asdf.sh"
    source_if_exists "$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash"
elif [ -d "$HOME/.asdf" ]; then
    source_if_exists "$HOME/.asdf/asdf.sh"
    source_if_exists "$HOME/.asdf/completions/asdf.bash"
fi

# Curl
if [ -d /usr/local/opt/curl/bin ]; then
    export PATH="/usr/local/opt/curl/bin:$PATH"
fi

# Docker & Docker Compose
export DOCKER_COMPOSE_USER_ID=$(id -u)
export DOCKER_SCAN_SUGGEST=false

# Git: macOS/Homebrew
prepend_to_path_if_exists /usr/local/opt/git/libexec/git-core
source_if_exists /usr/local/etc/bash_completion.d/git-completion.bash
source_if_exists /usr/local/etc/bash_completion.d/git-prompt.sh
# Git: Debian
source_if_exists /usr/lib/git-core/git-sh-prompt

# Java
if [ -f /usr/libexec/java_home ]; then
    export JAVA_HOME=$(/usr/libexec/java_home)
fi

# Node/NPM
prepend_to_path_if_exists /usr/local/share/npm/bin
source_if_exists /usr/local/etc/bash_completion.d/npm

# Visual Studio Code
prepend_to_path_if_exists "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
if type code &>/dev/null; then
    export EDITOR="code --wait"
    export VISUAL="code --wait"
fi

# OpenSSL (via Homebrew)
if [ -d $__openssl_brew_prefix ]; then
    export LIBRARY_PATH=$LIBRARY_PATH:"$__openssl_brew_prefix/lib/"
fi

# rbenv
if type rbenv &>/dev/null && (! asdf current ruby &>/dev/null); then
    export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl)"

    eval "$(rbenv init -)"
fi

# Ruby
if [ -d /opt/ruby/bin ]; then
    export PATH=/opt/ruby/bin:$PATH
    export GEM_SPEC_CACHE=/opt/ruby/gems/spec_cache
    export BUNDLE_PATH=/opt/ruby/gems
fi

# zoxide
if type zoxide &>/dev/null; then
    source_if_exists /usr/local/etc/profile.d/z.sh

    export _ZO_RESOLVE_SYMLINKS=1

    eval "$(zoxide init bash)"
fi

# Do this almost-last to allow host-specific overrides
if [ $(uname) == "Darwin" ]; then
    source_if_exists "$HOME/.bashrc.$(scutil --get LocalHostName)"
else
    source_if_exists "$HOME/.bashrc.$(hostname -s)"
fi

# Do this next-to-last to use host-specific overrides
source_if_exists "$HOME/.bash_prompt"

# Do this last-last to ensure that `history` is at the end
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND} history -a"
