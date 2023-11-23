
resource "aws_apprunner_service" "service" {
  service_name = var.name

  source_configuration {
    image_repository {
      image_identifier      = var.image
      image_repository_type = "ECR"
      image_configuration {
        port = var.application_port
      }
    }
    authentication_configuration {
      access_role_arn = var.access_role_arn
    }
    auto_deployments_enabled = false
  }

  health_check_configuration {
    protocol = "HTTP"
    path     = var.healthcheck_path
  }

  network_configuration {
    ingress_configuration {
      is_publicly_accessible = true
    }
  }
}


resource "aws_apprunner_custom_domain_association" "domain" {
  domain_name          = "${var.name}.enact-it.training"
  service_arn          = aws_apprunner_service.service.arn
  enable_www_subdomain = false
}

data "aws_route53_zone" "zone" {
  zone_id = var.hosted_zone_id
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.zone.id
  name    = var.name
  type    = "CNAME"
  ttl     = 300
  records = [aws_apprunner_custom_domain_association.domain.dns_target]
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for record in aws_apprunner_custom_domain_association.domain.certificate_validation_records : record.name => record.value
  }
  zone_id = data.aws_route53_zone.zone.id
  name    = trimsuffix(each.key, "${var.name}.${var.domain_name}")
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}
