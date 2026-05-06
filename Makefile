ifndef $(COMPONENT)
	COMPONENT := $(shell basename ${PWD})
endif

ENV?=discovery
LOCATION?=us

GLOBAL_PATH := $(shell git rev-parse --show-toplevel)

.PHONY: init validate fmt plan apply workspace

BACKEND_BUCKET := agent-space-449923
BACKEND_PREFIX := gemini-foundations/$(COMPONENT)

TFVARS := -var-file=$(GLOBAL_PATH)/variables/env/$(LOCATION)/default.tfvars \
	-var-file=$(GLOBAL_PATH)/variables/env/$(LOCATION)/$(ENV).tfvars \
	-var-file=$(GLOBAL_PATH)/component/$(COMPONENT)/env/${ENV}.tfvars

PLAN := tfplan
PLAN_TEXT := tfplan.txt
PLAN_JSON := tfplan.json

_log_info:
	@echo varfiles $(TFVARS)
	@echo tfplan $(PLAN_TEXT)
	@echo backend_prefix $(BACKEND_PREFIX) 
	@echo component $(COMPONENT)

validate: 
	terraform validate

fmt: 
	terraform fmt

init: 
	terraform init \
		-backend-config=bucket=$(BACKEND_BUCKET) \
		-backend-config=prefix=$(BACKEND_PREFIX) \
		-reconfigure

workspace:
	terraform workspace select $(ENV) || terraform workspace new $(ENV)

plan: init validate workspace
	terraform plan -no-color \
		$(TFVARS) \
		-out $(PLAN)
	terraform show -no-color $(PLAN) > $(PLAN_TEXT)
	terraform show -json $(PLAN) > $(PLAN_JSON)

apply: workspace
	terraform apply \
		-auto-approve \
		$(PLAN)