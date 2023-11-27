data "aws_route53_zone" "zone" {
  zone_id = var.hosted_zone_id
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for record in var.certificate_validation_records : record.name => record.value
  }
  zone_id = data.aws_route53_zone.zone.id
  name    = trimsuffix(each.key, "${var.name}.${var.domain_name}")
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}
