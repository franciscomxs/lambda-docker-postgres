### ### ### ### ### ### ### ### ### ### ### ###
# Configurações:
### ### ### ### ### ### ### ### ### ### ### ###

# AWS_ACCOUNT_ID	?= 954767414836
AWS_REGION		?= sa-east-1
ARN 			?= arn:aws:iam::$(AWS_ACCOUNT_ID):role/AwsLambdaFullAccess
APP 			?= app_name
VERSION 		?= 0.0.1

### ### ### ### ### ### ### ### ### ### ### ###
# Funções relativas ao SETUP de produção:
### ### ### ### ### ### ### ### ### ### ### ###

_setup_ecr:
	aws ecr describe-repositories --repository-names $(APP) || aws ecr create-repository --repository-name $(APP)

_setup_lambda:
	aws lambda create-function \
		--function-name $(APP) \
		--role $(ARN) \
		--package-type Image \
		--code ImageUri=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(APP):$(VERSION) \
		--memory-size 512 \
		--timeout 60

setup: _setup_ecr _build _login _tag _push _setup_lambda

### ### ### ### ### ### ### ### ### ### ### ###
# Funções relativas à automatização de release
### ### ### ### ### ### ### ### ### ### ### ###

_build:
	docker build -t $(APP) .

_login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.sa-east-1.amazonaws.com

_tag: _login _build
	docker tag $(APP):latest $(AWS_ACCOUNT_ID).dkr.ecr.sa-east-1.amazonaws.com/$(APP):$(VERSION)

_push: _tag
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.sa-east-1.amazonaws.com/$(APP):$(VERSION)

_update: _push
	aws lambda update-function-code \
		--function-name $(APP) \
		--image-uri $(AWS_ACCOUNT_ID).dkr.ecr.sa-east-1.amazonaws.com/$(APP):$(VERSION)

release: _update

invoke_remote:
	aws lambda invoke --function-name $(APP) --payload fileb://input.json ./output.json

### ### ### ### ### ### ### ### ### ### ### ###
# Funções relativas ao ambiente de desenvolvimento
### ### ### ### ### ### ### ### ### ### ### ###

_clean_images:
	docker rm -f $(docker ps -a -q)

_clean_volumes:
	docker volume rm $(docker volume ls -q)

_dev_build:
	docker-compose -f ./docker-compose-dev.yml build

clean: _clean_images _clean_volumes

# Alternativamente:
#
# 	docker run --rm -it --entrypoint /bin/bash app
#
bash:
	docker-compose -f ./docker-compose-dev.yml exec app sh

console:
	docker-compose -f ./docker-compose-dev.yml exec app sh -c bin/console

# Alternativamente:
#
#   docker run -p 9000:8080 app
#
run: _dev_build
	docker-compose -f ./docker-compose-dev.yml up

invoke_local:
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d @input.json

test: _dev_build
	docker-compose -f docker-compose-dev.yml run --entrypoint /entrypoint.sh app bundle exec rspec
