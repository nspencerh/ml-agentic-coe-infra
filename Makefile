ifndef $(COMPONENT)
	COMPONENT := $(shell basename ${PWD})
endif

ENV?=discovery
LOCATION?=us
QUALIFIER?=ml-ds-pp-hub
PROJECT_ID?=tu-machinelearning-ds-1
BACKEND_SERVICE_ACCOUNT?=cicd-backend-$(QUALIFIER)@$(PROJECT_ID).iam.gserviceaccount.com
DEPLOY_SERVICE_ACCOUNT?=cicd-deploy-$(QUALIFIER)@$(PROJECT_ID).iam.gserviceaccount.com

GLOBAL_PATH := $(shell git rev-parse --show-toplevel)

.PHONY: init validate fmt plan apply workspace

BACKEND_BUCKET := cicd-tfstate-$(PROJECT_ID)-ause1-$(QUALIFIER)
BACKEND_PREFIX := tfstate/$(COMPONENT)

TFVARS := -var-file=$(GLOBAL_PATH)/variables/env/$(LOCATION)/default.tfvars \
	-var-file=$(GLOBAL_PATH)/variables/env/$(LOCATION)/$(ENV).tfvars \
	-var-file=$(GLOBAL_PATH)/component/$(COMPONENT)/env/${ENV}.tfvars

ifdef TARGET
	TARGET := -target $(TARGET)
else
	TARGET := 
endif

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
		-backend-config=impersonate_service_account=$(BACKEND_SERVICE_ACCOUNT) \
		-reconfigure

workspace:
	terraform workspace select $(ENV) || terraform workspace new $(ENV)

plan: init validate workspace
	terraform plan -no-color \
		-var="deploy_service_account=$(DEPLOY_SERVICE_ACCOUNT)" \
		$(TFVARS) $(TARGET) \
		-out $(PLAN)
	terraform show -no-color $(PLAN) > $(PLAN_TEXT)
	terraform show -json $(PLAN) > $(PLAN_JSON)

 apply: workspace
	terraform apply \
 		-auto-approve \
		$(PLAN)