.ONESHELL:
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKE := $(make)
DATETIME_FORMAT := %(%Y-%m-%d %H:%M:%S)T

.SUFFIXES:
.DELETE_ON_ERROR:
.DEFAULT_GOAL := help

CONTAINERDIR ?= $(shell pwd)
APPTAINER_BIN ?= $(shell command -v apptainer 2>/dev/null || command -v singularity 2>/dev/null || echo "")

.PHONY: help
help:  ## Prints this usage.
	@printf 'Recipes\n=======\n' && grep --no-filename -E '^[a-zA-Z0-9-][^:[:space:]]+:.*##'  $(MAKEFILE_LIST) | sed -E 's/:.*##/: /'

MAKEFILE_ORIGINS := default environment environment\ override file command\ line override automatic \%

PRINTVARS_MAKEFILE_ORIGINS_TARGETS += $(patsubst %,printvars/%,$(MAKEFILE_ORIGINS))

.PHONY: $(PRINTVARS_MAKEFILE_ORIGINS_TARGETS)
$(PRINTVARS_MAKEFILE_ORIGINS_TARGETS):
	@$(foreach V, $(sort $(.VARIABLES)), \
		$(if $(filter $(@:printvars/%=%), $(origin $V)), \
			$(info $V=$($V) ($(value $V)))))

.PHONY: printvars
printvars: printvars/file # Print all Makefile variables (file origin).

.PHONY: printvar-%
printvar-%: # Print one Makefile variable.
	@echo '($*)'
	@echo '  origin = $(origin $*)'
	@echo '  flavor = $(flavor $*)'
	@echo '   value = $(value  $*)'

$(CONTAINERDIR)/sleap.sif: Singularity
	@ echo "Building container image: $(CONTAINERDIR)/sleap.sif"
ifeq (, $(APPTAINER_BIN))
	$(error apptainer or singularity not found in PATH. If you're running this on a cluster, you may need to allocate a compute node, and if you are already on a compute node, you may need to load the apptainer module via 'module load apptainer')
endif
	$(APPTAINER_BIN) build $@ Singularity 

.PHONY: container
container: $(CONTAINERDIR)/sleap.sif ## Build the container image.

