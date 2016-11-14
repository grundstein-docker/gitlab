#!/bin/bash

GITLAB_VERSION=8.13.5
IP=172.18.0.6

source ./ENV.sh
source ../../bin/tasks.sh

function build() {
  echo-start "build"

  docker pull sameersbn/gitlab:$GITLAB_VERSION

  echo-finished "build"
}

function run() {
  remove

  echo-start "run"

  docker run \
    --hostname $HOSTNAME \
    --name $CONTAINER_NAME \
    --detach \
    --env 'DB_ADAPTER=postgresql' \
    --env "DB_HOST=$(cat ../postgres/SERVER_IP)" \
    --env "REDIS_HOST=$(cat ../redis/SERVER_IP)" \
    --env 'REDIS_PORT=6379' \
    --publish $HOST_PORT_22:$CONTAINER_PORT_22 \
    --env "GITLAB_HOST=$HOSTNAME" \
    --env "GITLAB_PORT=$HOST_PORT_80" \
    --env "GITLAB_SSH_PORT=$HOST_PORT_22" \
    --env "DB_NAME=$GITLAB_DB_NAME" \
    --env "DB_USER=$GITLAB_DB_USER" \
    --env "DB_PASS=$GITLAB_DB_PASS" \
    --env "GITLAB_SECRETS_DB_KEY_BASE=$GITLAB_SECRETS_DB_KEY_BASE" \
    --env "GITLAB_SECRETS_SECRET_KEY_BASE=$GITLAB_SECRETS_SECRET_KEY_BASE" \
    --env "GITLAB_SECRETS_OTP_KEY_BASE=$GITLAB_SECRETS_OTP_KEY_BASE" \
    --env "OAUTH_GITHUB_API_KEY=$OAUTH_GITHUB_API_KEY" \
    --env "OAUTH_GITHUB_APP_SECRET=$OAUTH_GITHUB_APP_SECRET" \
    --env "SMTP_USER=$GITLAB_SMTP_USER" \
    --env "SMTP_PASS=$GITLAB_SMTP_PASS" \
    --volume $DATA_DIR/gitlab/data:/home/git/data \
    --volume $DATA_DIR/gitlab/logs:/home/git/gitlab/log \
    --net user-defined \
    --ip $IP \
    sameersbn/gitlab:$GITLAB_VERSION

  ip $IP

  echo-finished "run"
}

function rund() {
  remove

  echo-start "rund"

  docker run \
    --hostname $HOSTNAME \
    --name $CONTAINER_NAME \
    -it \
    --env 'DB_ADAPTER=postgresql' \
    --env "DB_HOST=$(cat ../postgres/SERVER_IP)" \
    --env "REDIS_HOST=$(cat ../redis/SERVER_IP)" \
    --env 'REDIS_PORT=6379' \
    --publish $HOST_PORT_22:$CONTAINER_PORT_22 \
    --env "GITLAB_HOST=$HOSTNAME" \
    --env "GITLAB_PORT=$HOST_PORT_80" \
    --env "GITLAB_SSH_PORT=$HOST_PORT_22" \
    --env "DB_NAME=$GITLAB_DB_NAME" \
    --env "DB_USER=$GITLAB_DB_USER" \
    --env "DEBUG=true" \
    --env "DB_PASS=$GITLAB_DB_PASS" \
    --env "GITLAB_SECRETS_DB_KEY_BASE=$GITLAB_SECRETS_DB_KEY_BASE" \
    --env "GITLAB_SECRETS_SECRET_KEY_BASE=$GITLAB_SECRETS_SECRET_KEY_BASE" \
    --env "GITLAB_SECRETS_OTP_KEY_BASE=$GITLAB_SECRETS_OTP_KEY_BASE" \
    --env "OAUTH_GITHUB_API_KEY=$OAUTH_GITHUB_API_KEY" \
    --env "OAUTH_GITHUB_APP_SECRET=$OAUTH_GITHUB_APP_SECRET" \
    --env "SMTP_USER=$GITLAB_SMTP_USER" \
    --env "SMTP_PASS=$GITLAB_SMTP_PASS" \
    --volume $DATA_DIR/gitlab/data:/home/git/data \
    --volume $DATA_DIR/gitlab/logs:/home/git/gitlab/log \
    --net user-defined \
    --ip $IP \
    sameersbn/gitlab:$GITLAB_VERSION

  ip $IP

  echo-finished "rund"
}

function debug() {
  remove
  build

  echo-start "connecting debug"

  docker run \
    --interactive \
    --tty \
    --name "$CONTAINER_NAME" \
    --entrypoint=sh "sameersbn/gitlab:$GITLAB_VERSION"
}

function backup() {
  echo-start "backup"

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

  echo-finished "backup"
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
