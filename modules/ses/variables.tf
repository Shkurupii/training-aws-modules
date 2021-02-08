variable "domain_name" {
  type = string
  description = "Domain Name"
}

variable "aws_ses_mail_bucket_name" {
  type = string
  description = "S3 Bucket for Amazon SES incoming mails"
}
