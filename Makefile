SHELL := /usr/bin/env bash
.SHELLFLAGS := -eo pipefail -O xpg_echo -o errtrace -o functrace -c
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKE := $(make)
DATETIME_FORMAT := %(%Y-%m-%d %H:%M:%S)T

.SUFFIXES:
.DELETE_ON_ERROR:
GROUP_NAME := $(shell id -Gnz | tr "\0" "\n" | grep -vE '^(all|test)$$' | head -n 1 )
USER_NAME := $(shell id -un)

APPTAINER_BIN ?= $(shell command -v apptainer 2>/dev/null || command -v singularity 2>/dev/null)

sleap.sif: Singularity
	$(APPTAINER_BIN) build $@ Singularity 


