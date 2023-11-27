push:
	aws ecr get-login-password \
		--region eu-west-1 \
	| docker login \
		--username AWS \
		--password-stdin 623040704282.dkr.ecr.eu-west-1.amazonaws.com

	DOCKER_DEFAULT_PLATFORM=linux/amd64 docker push 623040704282.dkr.ecr.eu-west-1.amazonaws.com/problematic-project:latest
	DOCKER_DEFAULT_PLATFORM=linux/amd64 docker push 623040704282.dkr.ecr.eu-west-1.amazonaws.com/wrongsecrets:latest
	DOCKER_DEFAULT_PLATFORM=linux/amd64 docker push 623040704282.dkr.ecr.eu-west-1.amazonaws.com/juiceshop:latest

plan:
	terraform plan \
		-target="aws_iam_role.apprunner" \
		-target="data.aws_iam_policy_document.apprunner_policy" \
		-target="aws_ecr_repository.juiceshop" \
		-target="aws_ecr_repository.wrongsecrets" \
		-target="aws_ecr_repository.problematic_project" \
		-target="module.juiceshop" \
		-target="module.wrongsecrets" \
		-target="module.problematic_project"


apply:
	terraform apply \
	-target="aws_iam_role.apprunner" \
	-target="data.aws_iam_policy_document.apprunner_policy" \
	-target="aws_ecr_repository.juiceshop" \
	-target="aws_ecr_repository.wrongsecrets" \
	-target="aws_ecr_repository.problematic_project" \
	-target="module.juiceshop" \
	-target="module.wrongsecrets" \
	-target="module.problematic_project" \
	-auto-approve
	terraform apply -auto-approve