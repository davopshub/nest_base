
.PHONY: help build-img start destroy fresh stop ps push-ecr auth-ecr tag-ecr

IMG_NAME=nest_base_image
DOCKERFILE=Dockerfile_base
AWSCLI_USER=zzzzzz
CONTAINER-PHP=php
CONTAINER-DB=db
VOLUME_DB=laravel-blog_db-data
AWS_REGION=us-east-1
AWS_ACCOUNTID=XXXXXXXX
VERSION_IMG=1.0

help: ## Print help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)


build-img: ## Build image
	@docker build  -t ${IMG_NAME}:${VERSION_IMG}  --no-cache . -f ./${DOCKERFILE}

auth-ecr: ## authenticate to AWS ECR repo
	@export AWS_PROFILE=${AWSCLI_USER} && export AWS_REGION=${AWS_REGION} && \
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNTID}.dkr.ecr.${AWS_REGION}.amazonaws.com

cree-repo-ecr: ## creer un repo dans aws ecr avec le meme nom que celui de l'image 
	@export AWS_PROFILE=${AWSCLI_USER} && export AWS_REGION=${AWS_REGION} && \
	aws ecr create-repository --repository-name ${IMG_NAME}

tag-ecr: ## tag and push to aws ecr
	@docker tag ${IMG_NAME}:${VERSION_IMG} ${AWS_ACCOUNTID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMG_NAME}:${VERSION_IMG}

push-ecr: ## tag and push image to AWS ECR
	@docker push ${AWS_ACCOUNTID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMG_NAME}:${VERSION_IMG}

deploy-ecr: auth-ecr tag-ecr push-ecr ## authenticate, tag and push to AWS ECR repo

	
# ps: ## Show containers
# 	@docker  ps

# start: ## Start and recreate all containers 
# 	@docker compose up --force-recreate -d

# fresh: stop destroy build start ## Stop destroy , recreate and start all and Restart  all containers and volumes from scratch

# stop: ## Stop -  all containers 
# 	@docker compose stop

# restart: stop start ## Stop and Restart  all containers

# destroy: stop ## stop and destroy   all Containers  and all Volumes
# 	@docker compose down
# 	@if [ "$(SHELL docker volume ls --filter name=${VOLUME_DB} --format {{.Name}})" ]; then \
# 	   @docker volume rm ${VOLUME_DB}; \
# 	fi

# logs: ## Print all docker logs  
# 	@docker compose logs -f