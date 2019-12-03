
ROOT_DIR	:= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all:
	@echo 'Available make targets:'
	@grep '^[^#[:space:]^\.PHONY.*].*:' Makefile

.PHONY: create-task-role
create-task-role:
	aws cloudformation create-stack --stack-name SSMTaskRole \
	--template-body file://cloudformation/base/task-iam.yml \
	--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM

.PHONY: create-ssm-role
create-ssm-role:
	aws cloudformation create-stack --stack-name SSMAssumeRole \
	--template-body file://cloudformation/ssm/ssm-iam.yml \
	--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM

.PHONY: delete-task-role
delete-task-role:
	aws cloudformation delete-stack --stack-name SSMTaskRole

.PHONY: delete-ssm-role
delete-ssm-role:
	aws cloudformation delete-stack --stack-name SSMAssumeRole

.PHONY: ecr-login
ecr-login:
	aws ecr get-login --no-include-email | bash

.PHONY: build
build:
	cd examples/redis && docker build . -t ssm-agent:latest

.PHONY: push
push: ecr-login
	docker tag ssm-agent:latest \
	$(shell aws ecr describe-repositories --repository-names ssm-agent \
	| jq '.repositories[0].repositoryUri' | tr -d '"'):latest
	docker push \
	$(shell aws ecr describe-repositories --repository-names ssm-agent \
	| jq '.repositories[0].repositoryUri' | tr -d '"'):latest

.PHONY: setup
setup:
	aws cloudformation create-stack --stack-name ContainerRepository \
	--template-body file://cloudformation/base/repository.yml

.PHONY: stack-status
stack-status:
	aws cloudformation describe-stacks --stack-name ContainerRepository

.PHONY: create-activation
create-activation:
	aws ssm create-activation --default-instance-name FargateContainers --iam-role AutomationServiceRole --registration-limit 100 --region us-west-2 --tags "Key=App,Value=FargateDemo"

.PHONY: render-task-parameters
render-task-parameters:
	echo ParameterKey=TaskRoleArn,ParameterValue=\
	$(shell aws cloudformation describe-stacks --stack-name SSMTaskRole | \
	jq '.Stacks[0].Outputs[0].OutputValue' | tr -d '"') \
	ParameterKey=ExecutionRoleArn,ParameterValue=$(shell aws cloudformation describe-stacks --stack-name SSMTaskRole | \
	jq '.Stacks[0].Outputs[1].OutputValue' | tr -d '"') \
	ParameterKey=ServiceName,ParameterValue=FargateSSMAgentDemo \
	ParameterKey=ImageUrl,ParameterValue=$(shell aws ecr describe-repositories \
	--repository-names ssm-agent | jq '.repositories[0].repositoryUri' | tr -d '"'):latest > \
	cloudformation/task/parameters.txt

.PHONY: create-task
create-task:
	aws cloudformation create-stack --stack-name FargateSSMAgentDemo \
	--template-body file://cloudformation/task/simple-container.yml \
	--parameters $(shell cat cloudformation/task/parameters.txt)

.PHONY: delete-task
delete-task:
	aws cloudformation delete-stack --stack-name FargateSSMAgentDemo

.PHONY: teardown
teardown:
	aws cloudformation delete-stack --stack-name ContainerRepository
	aws cloudformation delete-stack --stack-name SSMTaskRole
	aws cloudformation delete-stack --stack-name FargateSSMAgentDemo