provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Environment = "Production"
      App         = "JuiceShopWrongSecretsAndProblematicProject"
    }
  }
}

locals {
  juiceshop_instances = toset([
    "alpha",
    "bravo",
    "charlie",
    "delta",
    // "echo",
    // "foxtrot",
    // "golf",
    // "hotel",
    // "india",
    // "juliett",
  ])
}

# Create an IAM role for App Runner to use and pull images from ECR
resource "aws_iam_role" "apprunner" {
  name = "apprunner"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name   = "apprunner"
    policy = data.aws_iam_policy_document.apprunner_policy.json
  }
}

# Allow App Runner to pull images from ECR
data "aws_iam_policy_document" "apprunner_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}

resource "aws_ecr_repository" "juiceshop" {
  name = "juiceshop"
}

resource "aws_ecr_repository" "wrongsecrets" {
  name = "wrongsecrets"
}

resource "aws_ecr_repository" "problematic_project" {
  name = "problematic-project"
}

module "juiceshop" {
  for_each         = local.juiceshop_instances
  source           = "./modules/app-runner"
  name             = "juiceshop-${each.key}"
  image            = "${aws_ecr_repository.juiceshop.repository_url}:latest"
  access_role_arn  = aws_iam_role.apprunner.arn
  application_port = 3000
  healthcheck_path = "/#/"
}

module "wrongsecrets" {
  source           = "./modules/app-runner"
  name             = "wrongsecrets"
  image            = "${aws_ecr_repository.wrongsecrets.repository_url}:latest"
  access_role_arn  = aws_iam_role.apprunner.arn
  application_port = 8080
  healthcheck_path = "/"
}

module "problematic_project" {
  source           = "./modules/app-runner"
  name             = "problematic-project"
  image            = "${aws_ecr_repository.problematic_project.repository_url}:latest"
  access_role_arn  = aws_iam_role.apprunner.arn
  application_port = 5000
  healthcheck_path = "/posts/"
}

module "juiceshop_certificates" {
  for_each                       = module.juiceshop
  source                         = "./modules/certificates"
  name                           = module.juiceshop[each.key].name
  certificate_validation_records = module.juiceshop[each.key].certificate_validation_records
}

module "wrongsecrets_certificates" {
  source                         = "./modules/certificates"
  name                           = module.problematic_project.name
  certificate_validation_records = module.problematic_project.certificate_validation_records
}

module "problematic_project_certificates" {
  source                         = "./modules/certificates"
  name                           = module.wrongsecrets.name
  certificate_validation_records = module.wrongsecrets.certificate_validation_records
}
