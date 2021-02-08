ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: gen _gen-main _gen-modules _update-tf-docs

CURRENT_DIR     = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TF_MODULES      = $(sort $(dir $(wildcard $(CURRENT_DIR)modules/*/)))
TF_DOCS_VERSION = 0.10.1

# Adjust your delimiter here or overwrite via make arguments
DELIM_START = <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
DELIM_CLOSE = <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

gen: _update-tf-docs
	@echo "################################################################################"
	@echo "# Terraform-docs generate"
	@echo "################################################################################"
	@$(MAKE) --no-print-directory _gen-main
	@$(MAKE) --no-print-directory _gen-modules

_gen-main:
	@echo "------------------------------------------------------------"
	@echo "# Main module"
	@echo "------------------------------------------------------------"
	@if docker run --rm \
		-v $(CURRENT_DIR):/data \
		-e DELIM_START='$(DELIM_START)' \
		-e DELIM_CLOSE='$(DELIM_CLOSE)' \
		cytopia/terraform-docs:$(TF_DOCS_VERSION) \
		terraform-docs-replace md README.md; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi


_gen-modules:
	@$(foreach module,\
		$(TF_MODULES),\
		DOCKER_PATH="modules/$(notdir $(patsubst %/,%,$(module)))"; \
		echo "------------------------------------------------------------"; \
		echo "# $${DOCKER_PATH}"; \
		echo "------------------------------------------------------------"; \
		if docker run --rm \
			-v $(CURRENT_DIR):/data \
			-e DELIM_START='$(DELIM_START)' \
			-e DELIM_CLOSE='$(DELIM_CLOSE)' \
			cytopia/terraform-docs:$(TF_DOCS_VERSION) \
			terraform-docs-replace md $${DOCKER_PATH}/README.md; then \
			echo "OK"; \
		else \
			echo "Failed"; \
			exit 1; \
		fi; \
	)

_update-tf-docs:
	docker pull cytopia/terraform-docs:$(TF_DOCS_VERSION)
