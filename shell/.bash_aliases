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

git:github:user() {
    git config --unset-all user.name;
    git config --add user.name vdauchy;

    git config --unset-all user.email
    git config --add user.email 26772554+vdauchy@users.noreply.github.com
}

git:tag:delete:origin() {
    git tag --delete ${@}
    git push --delete origin ${@}
}

docker:workdir() {
    docker image inspect $1 | jq -r ".[].Config.WorkingDir";
}

docker:prune() {
    docker system prune -fa;
    docker volume prune -f;
}

docker:rm() {
    docker ps -q -a | xargs --no-run-if-empty docker rm -f
}

docker:rmi() {
    docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi -f
}

docker:df() {
    docker system df
}

docker:run() {
    docker:lazy-pull ${1};
    docker run \
        --interactive \
        --read-only \
        --rm \
        --tty \
        --user $(id -u ${USER}):$(id -g ${USER}) \
        --tmpfs /tmp \
        ${@}
}

docker:run:pwd() {
    docker:run --volume $(pwd):$(docker:workdir "${1}") ${@}
}

docker:run:php:8.1() {
    docker:run:pwd vdauchy/php-cli-alpine:8.1 ${@}
}

docker:run:php:8.0() {
    docker:run:pwd vdauchy/php-cli-alpine:8.0 ${@}
}

docker:run:php:7.4() {
    docker:run:pwd vdauchy/php-cli-alpine:7.4 ${@}
}

docker:run:php:qa() {
    docker run \
        --init \
        --interactive \
        --read-only \
        --rm \
        --tmpfs /tools/.composer/cache \
        --tty \
        --user $(id -u ${USER}):$(id -g ${USER}) \
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

dotfile:refresh() {
    ~/projects/dotfiles/bootstrap;
}

dotfile:gg() {
    (cd ~/projects/dotfiles && gg)
}

dotfile:edit() {
    (gedit ~/.bash_* &)
}

term:nuke() {
    (cat /dev/null > ~/.bash_history && history -c && kill -9 $(ps aux | grep term | awk '{print $2}'))
}

swap:nuke() {
	(sudo swapoff -a; sudo swapon -a);
}

include () {
    [[ -f "$1" ]] && source "$1"
}

include ~/.gdc
include ~/.github
include ~/.blackfire