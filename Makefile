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
.PHONY: stack.prepare_lambda stack.generate_final_template stack.validate stack-setup stack-deploy

CFN_DIR := deploy/cloudformation/
LAMBDA_DIR = deploy/awslambda/src
CFN_SCRIPTS_DIR := ${CFN_DIR}/scripts
CFN_TEMPLATES_DIR := ${CFN_DIR}/templates
CNF_MAIN_TEMPLATE_PATH := ${CFN_TEMPLATES_DIR}/resources.yml
CNF_FINAL_TEMPLATE_PATH := ${CFN_TEMPLATES_DIR}/resources-final.yml
CNF_STACK_NAME := $$(if [ "${ENVIRONMENT}" = "production" ]; then echo ${PROJECT}; else echo "${PROJECT}-${GIT_PR}"; fi)

stack.prepare_lambda: ## Install packages for lambda function with a requirements.txt file
	@echo "Installing packages for lambda functions"
	@for f in $(shell find $(LAMBDA_DIR) -type f -name 'requirements.txt' | xargs dirname | sort -u ); do\
		echo $${f};\
		pip install -r $${f}/requirements.txt --target $${f};\
	done

stack.generate_final_template: ## Adds state machine and path for s3 files on cloudformation final template
	@echo "\033[0;32mGenerating and uploading final template to S3 \033[0m"
	@python3 \
		${CFN_SCRIPTS_DIR}/inject_state_machine_cfn.py \
		-s deploy/stepfunction/state-machine.json \
		-c ${CNF_MAIN_TEMPLATE_PATH} \
		-o ${CNF_FINAL_TEMPLATE_PATH}
	@aws cloudformation package \
		--template-file ${CNF_FINAL_TEMPLATE_PATH} \
		--s3-bucket ${CNF_DEPLOY_BUCKET} \
		--s3-prefix ${CNF_DEPLOY_BUCKET_PREFIX} \
		--output-template-file ${CNF_FINAL_TEMPLATE_PATH}

stack.validate: ## Validates Cloudformation locally
	@echo "\033[0;32mValidating final template \033[0m"
	@aws cloudformation validate-template --template-body file://${CNF_FINAL_TEMPLATE_PATH} --output table

stack-setup: stack.prepare_lambda stack.generate_final_template ## Setup stack for deploy

stack-deploy: ## Deploy Cloudformation stack on AWS
	@echo "\033[0;32mDeploying ${CNF_STACK_NAME} on ${AWS_DEFAULT_REGION}:${AWS_DEFAULT_AVAILABILITY_ZONE} \033[0m"
	@echo "\033[0;32mDeploy started on `date` \033[0m"
	@aws cloudformation deploy \
		--stack-name ${CNF_STACK_NAME} \
		--template ${CNF_FINAL_TEMPLATE_PATH} \
		--s3-bucket ${CNF_DEPLOY_BUCKET} \
		--s3-prefix ${CNF_DEPLOY_BUCKET_PREFIX} \
		--role-arn ${CNF_ROLE_ARN} \
		--capabilities CAPABILITY_AUTO_EXPAND CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--tags \
			Environment=${ENVIRONMENT} \
			Project=${PROJECT} \
			Team=${TEAM} \
		--parameter-overrides \
			ProductionStack=${PROJECT} \
			Environment=${ENVIRONMENT} \
			AvailabilityZoneName=${AWS_DEFAULT_AVAILABILITY_ZONE} \
			ProjectVersion=${IMAGE_VERSION} \
			EC2KeyPairName=${EC2_KEY_PAIR_NAME}
	@echo "\033[0;32mDeploy ended on `date` \033[0m"

###############################################################################
# Deploy: ECR & Docker                                                        #
###############################################################################
.PHONY: docker-build ecr.login docker.check_registry docker.tag docker.push docker-deploy

deploy-container-aws: ## Push images to the ECR repository
	@echo "\033[0;32mPushing images to ${REPOSITORY_REGISTRY} started on `date` \033[0m"
	@docker push ${DOCKER_COMMIT_TAG}