#!/bin/bash

GITLAB_VERSION=8.6.1

source ./ENV.sh
source ../../bin/tasks.sh

function build() {
  echo "building: $CONTAINER_NAME"

  docker pull sameersbn/gitlab:$GITLAB_VERSION

  echo "build finished"
}

function run() {
  remove

  echo "starting container $CONTAINER_NAME"

  docker run \
    --hostname $HOSTNAME \
    --name $CONTAINER_NAME \
    --detach \
    --link magic-postgres:postgresql \
    --link magic-redis:redisio \
    --publish $HOST_PORT_22:$CONTAINER_PORT_22 \
    --env "GITLAB_HOST=$HOSTNAME" \
    --env "GITLAB_PORT=$HOST_PORT_80" \
    --env "GITLAB_SSH_PORT=$HOST_PORT_22" \
    --env "DB_NAME=$GITLAB_DB_NAME" \
    --env "DB_USER=$GITLAB_DB_USER" \
    --env "DB_PASS=$GITLAB_DB_PASS" \
    --env "GITLAB_SECRETS_DB_KEY_BASE=$GITLAB_SECRETS_DB_KEY_BASE" \
    --env "OAUTH_GITHUB_API_KEY=$OAUTH_GITHUB_API_KEY" \
    --env "OAUTH_GITHUB_APP_SECRET=$OAUTH_GITHUB_APP_SECRET" \
    --env "SMTP_USER=$GITLAB_SMTP_USER" \
    --env "SMTP_PASS=$GITLAB_SMTP_PASS" \
    --volume $DATA_DIR/gitlab/data:/home/git/data \
    --volume $DATA_DIR/gitlab/logs:/home/git/gitlab/log \
    sameersbn/gitlab:$GITLAB_VERSION

  ip

  echo "started docker container $CONTAINER_NAME"
}

function debug() {
  ./cli.sh remove
  ./cli.sh build

  echo "connecting to container $CONTAINER_NAME"
  docker run \
    --interactive \
    --tty \
    --name "$CONTAINER_NAME" \
    --entrypoint=sh "sameersbn/gitlab:$GITLAB_VERSION"
}

function backup() {
  echo "backup $CONTAINER_NAME"

  remove

  docker run \
    --name $CONTAINER_NAME \
    --interactive \
    --tty \
    --rm \
    --link magic-postgres:postgresql \
    --link magic-redis:redisio \
    --env "GITLAB_HOST=$HOSTNAME" \
    --env "GITLAB_PORT=$HOST_PORT_80" \
    --env "GITLAB_SSH_PORT=$HOST_PORT_22" \
    --env "DB_NAME=$GITLAB_DB_NAME" \
    --env "DB_USER=$GITLAB_DB_USER" \
    --env "DB_PASS=$GITLAB_DB_PASS" \
    --env "GITLAB_SECRETS_DB_KEY_BASE=$GITLAB_SECRETS_DB_KEY_BASE" \
    --env "OAUTH_GITHUB_API_KEY=$OAUTH_GITHUB_API_KEY" \
    --env "OAUTH_GITHUB_APP_SECRET=$OAUTH_GITHUB_APP_SECRET" \
    --volume $DATA_DIR/gitlab/data:/home/git/data \
    --volume $DATA_DIR/gitlab/logs:/home/git/gitlab/log \
    sameersbn/gitlab:$GITLAB_VERSION app:rake gitlab:backup:create

  run
}

function help() {
echo "
Container: $CONTAINER_NAME

Usage:

make [TASK]
./cli.sh [TASK]

TASKS:
 build  - build docker container
 run    - run docker container
 remove - remove container
 logs   - tail the container logs
 debug  - connect to container debug session
 stop   - stop container
 help   - this help text
"
}

if [ $1 ]
then
  function=$1
  shift
  $function $@
else
  help $@
fi
