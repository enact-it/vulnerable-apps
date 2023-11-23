variable "name" {
  description = "The name of the apprunner service"
  type        = string
}

variable "image" {
  description = "The image to use for the apprunner service"
  type        = string
}

variable "application_port" {
  description = "The port the application listens on"
  type        = number
}

variable "healthcheck_path" {
  description = "The healthcheck path"
  type        = string
  default     = "/"
}

variable "domain_name" {
  description = "The domain name to use"
  type        = string
  default     = "enact-it.training"
}

variable "hosted_zone_id" {
  description = "The ID of the Route53 Hosted Zone to use"
  type        = string
  default     = "Z06361802X634WNSXP9MG"
}

variable "access_role_arn" {
  description = "The ARN of the IAM role to use for App Runner"
  type        = string
}
