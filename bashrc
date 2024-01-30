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

function mkcd () {
    mkdir -p $1 && cd $1;
}

if [ $(uname) == "Darwin" ]; then
    __is_mac=1
    __short_hostname=$(scutil --get LocalHostName)
else
    __is_mac=0
    __short_hostname=$(hostname -s)
fi

# Reset
export PROMPT_COMMAND=

export HISTFILE="$HOME/.bash_history.$__short_hostname"
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000

export EDITOR="vim"
export VISUAL="vim"

export LANG=en_US.UTF-8
export LANGUAGE=en
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export TZ="America/New_York"

source_if_exists "$HOME/.bash_aliases"

# Homebrew
if type brew &>/dev/null; then
    __brew_prefix=$(brew --prefix)
    __brew_openssl_prefix=$(brew --prefix openssl)

    # Curl
    prepend_to_path_if_exists $__brew_prefix/opt/curl/bin

    # Git
    prepend_to_path_if_exists $__brew_prefix/opt/git/libexec/git-core
    source_if_exists $__brew_prefix/etc/bash_completion.d/git-completion.bash
    source_if_exists $__brew_prefix/etc/bash_completion.d/git-prompt.sh

    # OpenSSL
    if [ -d $__brew_openssl_prefix ]; then
        prepend_to_path_if_exists $__brew_openssl_prefix/bin
        export LIBRARY_PATH=$LIBRARY_PATH:"$__brew_openssl_prefix/lib/"

        # rbenv
        export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$__brew_openssl_prefix"
    fi
else
    # Git
    source_if_exists /usr/lib/git-core/git-sh-prompt
fi

# Docker
export DOCKER_SCAN_SUGGEST=false
export DOCKER_CLI_HINTS=false

# rbenv
if type rbenv &>/dev/null; then
    eval "$(rbenv init -)"
fi

# Visual Studio Code
if type code &>/dev/null; then
    export EDITOR="code --wait"
    export VISUAL="code --wait"
fi

# zoxide
if type zoxide &>/dev/null; then
    export _ZO_RESOLVE_SYMLINKS=1

    eval "$(zoxide init bash)"
fi

# Do this almost-last to allow host-specific overrides
source_if_exists "$HOME/.bashrc.$__short_hostname"

# Do this next-to-last to base the prompt on any host-specific overrides
source_if_exists "$HOME/.bash_prompt"

# Do this last-last to ensure that `history -a` is at the end
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND} history -a"
