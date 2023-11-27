variable "hosted_zone_id" {
  description = "The ID of the Route53 Hosted Zone to use"
  type        = string
  default     = "Z06361802X634WNSXP9MG"
}

variable "domain_name" {
  description = "The domain name to use"
  type        = string
  default     = "enact-it.training"
}

variable "name" {
  description = "The name of the apprunner service"
  type        = string
}

variable "certificate_validation_records" {
  type = set(object({
    name   = string
    status = string
    type   = string
    value  = string
  }))
  description = "Certificate validation records for app runner"
}
