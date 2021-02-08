provider "aws" {
}

terraform {
  required_version = "0.14.5"
}

data "aws_route53_zone" "dns_zone" {
  name = var.domain_name
  private_zone = false
}

resource "aws_ses_domain_identity" "amazonses_di" {
  domain = var.domain_name
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = data.aws_route53_zone.dns_zone.zone_id
  name = "_amazonses.${aws_ses_domain_identity.amazonses_di.id}"
  type = "TXT"
  ttl = "600"
  records = [
    aws_ses_domain_identity.amazonses_di.verification_token]
}

resource "aws_ses_domain_identity_verification" "amazonses_di_verification" {
  domain = aws_ses_domain_identity.amazonses_di.id

  depends_on = [
    aws_route53_record.amazonses_verification_record]
}

resource "aws_ses_receipt_rule_set" "amazonses_receipt_rule_set" {
  rule_set_name = "Main"
}

resource "aws_ses_receipt_rule" "amazonses_receipt_rule" {
  name = "Store"
  rule_set_name = aws_ses_receipt_rule_set.amazonses_receipt_rule_set.rule_set_name
  recipients = [
    var.domain_name]
  enabled = true
  scan_enabled = true

  s3_action {
    bucket_name = var.aws_ses_mail_bucket_name
    object_key_prefix = "mailbox"
    position = 1
  }
}

resource "aws_ses_active_receipt_rule_set" "amazonses_active_receipt_rule_set" {
  rule_set_name = "Main"
  depends_on = [
    aws_ses_receipt_rule_set.amazonses_receipt_rule_set]
}

resource "aws_ses_domain_dkim" "amazonses_domain_dkim" {
  domain = aws_ses_domain_identity.amazonses_di.domain
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count = 3
  zone_id = data.aws_route53_zone.dns_zone.zone_id
  name = "${element(aws_ses_domain_dkim.amazonses_domain_dkim.dkim_tokens, count.index)}._domainkey.${aws_ses_domain_identity.amazonses_di.id}"
  type = "CNAME"
  ttl = "600"
  records = [
    "${element(aws_ses_domain_dkim.amazonses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
