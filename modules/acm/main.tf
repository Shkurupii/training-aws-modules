provider "aws" {
}

terraform {
  required_version = "0.14.5"
}

resource "aws_acm_certificate" "cert" {
  domain_name = var.domain_name
  subject_alternative_names = var.alternative_names
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

}

data "aws_route53_zone" "dns_zone" {
  name = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "dns_record" {
  for_each = {
  for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
    name = dvo.resource_record_name
    record = dvo.resource_record_value
    type = dvo.resource_record_type
    zone_id = data.aws_route53_zone.dns_zone.zone_id
  }
  }

  allow_overwrite = true
  name = each.value.name
  records = [
    each.value.record]
  ttl = 60
  type = each.value.type
  zone_id = each.value.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_record : record.fqdn]
}