output "certificate_validation_records" {
  value       = aws_apprunner_custom_domain_association.domain.certificate_validation_records
  description = "value of the certificate validation records"
}

output "name" {
  value       = var.name
  description = "name of the apprunner service"
}
