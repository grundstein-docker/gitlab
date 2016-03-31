CLI=./cli.sh

.PHONY: \
	all \
	dev \
	build \
	run \
	debug \
	logs \
	rm \
	stop \
	ip \
	backup \
	update \
	status \
	help


# TASKS

all: help

dev: run logs

build:
	@${CLI} $@

run:
	@${CLI} $@

debug:
	@${CLI} $@

logs:
	@${CLI} $@

rm:
	@${CLI} $@

stop:
	@${CLI} $@

ip:
	@${CLI} $@

backup:
	@${CLI} $@

update:
	@${CLI} $@

status:
	@${CLI} $@

help:
	@${CLI} $@
