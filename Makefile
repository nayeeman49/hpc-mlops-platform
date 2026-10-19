.PHONY: fmt validate plan apply monitoring-validate monitoring-plan monitoring-apply

fmt:
	terraform fmt -recursive

validate:
	terraform -chdir=infra init -backend=false
	terraform -chdir=infra validate
	terraform -chdir=monitoring init -backend=false
	terraform -chdir=monitoring validate

plan:
	terraform -chdir=infra plan

apply:
	terraform -chdir=infra apply

monitoring-validate:
	terraform -chdir=monitoring init -backend=false
	terraform -chdir=monitoring validate

monitoring-plan:
	terraform -chdir=monitoring plan

monitoring-apply:
	terraform -chdir=monitoring apply
