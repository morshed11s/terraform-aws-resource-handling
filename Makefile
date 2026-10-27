.PHONY: init fmt validate plan-dev plan-staging plan-prod destroy-dev tflint

init:
	terraform init

fmt:
	terraform fmt -recursive

validate: init
	terraform validate

plan-dev: init
	terraform plan -var-file="envs/dev.tfvars"

plan-staging: init
	terraform plan -var-file="envs/staging.tfvars"

plan-prod: init
	terraform plan -var-file="envs/prod.tfvars"

destroy-dev: init
	terraform destroy -var-file="envs/dev.tfvars"

tflint:
	tflint --init
	tflint
