#!/bin/bash

alias gc='git clone'
alias gg='git gui'
alias gk='gitk --all'

alias grep='grep --color=auto'

alias x-name='cat composer.json | jq -r ".name"'
alias x-dive='dive $(x-name)'
alias x-run='docker run --rm -ti --volume $(pwd):$(docker:workdir $(x-name)) $(x-name)'
alias x-build='docker build . -t $(x-name):latest'
alias x-rm='docker image rm $(x-name):latest -f'

alias php-phan='docker:run:php:qa phan --color'

docker:workdir() {
    docker image inspect $1 | jq -r ".[].Config.WorkingDir";
}

docker:clean() {
    docker system prune -fa;
    docker volume prune -f;
}

docker:run() {
    docker:lazy-pull ${1};
    docker run \
        --interactive \
        --read-only \
        --rm \
        --tty \
        --user $(id -u ${USER}):$(id -g ${USER}) \
        --volume $(pwd):$(docker:workdir ${1}) \
        --tmpfs /tmp \
        ${@}
}

docker:run:php:8.0() {
    docker:run vdauchy/php-cli-alpine:8.0 ${@}
}

docker:run:php:7.4() {
    docker:run vdauchy/php-cli-alpine:7.4 ${@}
}

docker:run:php:qa() {
    docker run \
        --init \
        --interactive \
        --read-only \
        --rm \
        --tmpfs /tools/.composer/cache \
        --tty \
        --volume "$(pwd)/tmp-phpqa:/tmp" \
        --volume "$(pwd):/project" \
        --workdir /project \
        jakzal/phpqa:alpine \
        ${@}
}

docker:dive() {
    docker:lazy-pull wagoodman/dive:latest;
    docker run \
        --interactive \
        --read-only \
        --rm \
        --tty \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        wagoodman/dive:latest \
        ${@}
}

docker:lazy-pull() {
    docker image inspect ${1} > /dev/null 2>&1 || docker pull ${1};
}