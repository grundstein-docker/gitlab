.PHONY: \
	all \
	dev \
	build \
	run \
	debug \
	logs \
	rm \
	stop \
	backup \
	help


# TASKS

all: help

dev: run logs

build:
	@./cli.sh build

run:
	@./cli.sh run

debug:
	@./cli.sh debug

logs:
	@./cli.sh logs

rm:
	@./cli.sh remove

stop:
	@./cli.sh stop

backup:
	@./cli.sh backup


# help output
help:
	@echo "\
Usage \n\
make TASK\n\
\n\
TASKS: \n\
	dev     - build then tail logs \n\
	build   - docker build container \n\
	run     - docker run container \n\
	debug   - connect to docker container \n\
	logs    - tail docker container logs \n\
	rm      - remove docker container \n\
	stop    - stop docker container \n\
	backup  - run gitlab backup task \n\
\n\
	help      - this help text \n\
"
