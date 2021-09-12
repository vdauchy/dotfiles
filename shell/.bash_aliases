#!/bin/bash

alias gc='git clone'
alias gg='git gui'
alias gk='gitk --all'

alias grep='grep --color=auto'

alias dive='docker run --rm -ti --volume /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest'

alias x-name='cat composer.json | jq -r ".name"'
alias x-dive='dive $(x-name)'
alias x-run='docker run --rm -ti --volume $(pwd):/usr/src/app --user $(id -u ${USER}):$(id -g ${USER}) $(x-name)'