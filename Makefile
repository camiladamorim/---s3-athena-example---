.PHONY: help pep8 checkcommit pushdev pushstage pushprod


#variáveis
TIME_NOW = `date`
GIT_COMMIT := $$(echo `git log -1 --pretty=%h`)


help:
	@grep -E '(^[a-zA-Z|0-9]+:.*?#.*$$)' $(MAKEFILE_LIST)

pep8: # Checks code style (PEP8)
	@flake8

checkcommit: # ve qual o ultimo commit
	@echo ${GIT_COMMIT}

makeenvs:
	@git add --all
	@git commit -m "stuff"
	@git checkout -b prod
	@git checkout -b stage
	@git checkout -b dev

pushdev: # push na branch dev
	@git checkout dev
	@git add --all
	@git commit -m "${TIME_NOW}"
	@git push origin dev

pushmaster: # push na branch dev
	@git checkout master
	@git add --all
	@git commit -m "${TIME_NOW}"
	@git push origin master

pushstage: # push na branch staging
	@git checkout stage
	@git add --all
	@git commit -m "${TIME_NOW}"
	@git push origin stage

pushprod: # push na branch produção
	@git checkout prod
	@git add --all
	@git commit -m "${TIME_NOW}"
	@git push origin prod










###############################################################################
# Deploy: Cloudformation                                                      #
###############################################################################
.PHONY: cloudformation


TEMPLATE_PATH := /home/camila/Desktop/git/nina/deploy/cloudformation.yaml
STACK_NAME := "ninastack"
ROLE_ARN := " "

cloudformation: ## Deploy Cloudformation stack on AWS
	@aws cloudformation deploy \
		--stack-name ${STACK_NAME} \
		--template ${TEMPLATE_PATH}\
		--role-arn ${ROLE_ARN}
		#		--s3-bucket bucket \