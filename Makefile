# Variables
ENV ?= terraform
TFVARS = environments/$(ENV).tfvars

.PHONY: plan apply destroy choose-deployment tf-run validate fmt

plan:
	@echo "Select Cloud Provider:"
	@echo "1) AWS"
	@echo "2) Azure"
	@echo "3) GCP"
	@echo "4) Hetzner"
	@read -p "Enter choice [1-4]: " cloud_choice; \
	case $$cloud_choice in \
		1) CLOUD=aws ;; \
		2) CLOUD=azure ;; \
		3) CLOUD=gcp ;; \
		4) CLOUD=hetzner ;; \
		*) echo "Invalid choice" && exit 1 ;; \
	esac; \
	$(MAKE) choose-deployment CLOUD=$$CLOUD ACTION=plan

apply:
	@echo "Select Cloud Provider:"
	@echo "1) AWS"
	@echo "2) Azure"
	@echo "3) GCP"
	@echo "4) Hetzner"
	@read -p "Enter choice [1-4]: " cloud_choice; \
	case $$cloud_choice in \
		1) CLOUD=aws ;; \
		2) CLOUD=azure ;; \
		3) CLOUD=gcp ;; \
		4) CLOUD=hetzner ;; \
		*) echo "Invalid choice" && exit 1 ;; \
	esac; \
	$(MAKE) choose-deployment CLOUD=$$CLOUD ACTION=apply

destroy:
	@echo "Select Cloud Provider:"
	@echo "1) AWS"
	@echo "2) Azure"
	@echo "3) GCP"
	@echo "4) Hetzner"
	@read -p "Enter choice [1-4]: " cloud_choice; \
	case $$cloud_choice in \
		1) CLOUD=aws ;; \
		2) CLOUD=azure ;; \
		3) CLOUD=gcp ;; \
		4) CLOUD=hetzner ;; \
		*) echo "Invalid choice" && exit 1 ;; \
	esac; \
	$(MAKE) choose-deployment CLOUD=$$CLOUD ACTION=destroy

choose-deployment:
	@if [ "$(CLOUD)" = "hetzner" ]; then \
		echo "Only Server Base available for Hetzner"; \
		DEPLOY_TYPE_DIR=server; \
		DEPLOY_TYPE_NAME=Server; \
	else \
		echo "Select Deployment Type for $(CLOUD):"; \
		echo "1) Kubernetes"; \
		echo "2) Server"; \
		read -p "Enter choice [1-2]: " dep_choice; \
		case $$dep_choice in \
			1) DEPLOY_TYPE_DIR=k8s; DEPLOY_TYPE_NAME=Kubernetes ;; \
			2) DEPLOY_TYPE_DIR=server; DEPLOY_TYPE_NAME=Server ;; \
			*) echo "Invalid choice" && exit 1 ;; \
		esac; \
	fi; \
	$(MAKE) tf-run CLOUD=$(CLOUD) DEPLOY_TYPE_DIR=$$DEPLOY_TYPE_DIR DEPLOY_TYPE_NAME=$$DEPLOY_TYPE_NAME ACTION=$(ACTION)

tf-run:
	@echo "==== Running Terraform $(ACTION) for $(CLOUD) / $(DEPLOY_TYPE_NAME) / env: $(ENV) ===="
	@cd modules/$(CLOUD)/$(DEPLOY_TYPE_DIR) && \
	terraform init && \
	terraform $(ACTION) -var-file=../../../$(TFVARS)

validate:
	@echo "==== Validating Terraform configuration ===="
	@terraform -chdir="./modules/aws" validate
	@terraform -chdir="./modules/azure" validate
	@terraform -chdir="./modules/gcp" validate
	@terraform -chdir="./modules/hetzner" validate

fmt:
	@echo "==== Formatting Terraform files ===="
	@terraform fmt -recursive
