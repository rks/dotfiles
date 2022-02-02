#!/usr/bin/env bash

brew install \
    asdf \
    coreutils \
    gawk \
    gnupg \
    openssl \
    readline

printf "standard-resolver\n" > $HOME/.gnupg/dirmngr.conf

for _plugin in golang nodejs ruby; do
    asdf install $_plugin latest
    asdf global $_plugin latest
done
