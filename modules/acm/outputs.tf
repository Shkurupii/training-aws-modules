output "cert_status" {
  value       = aws_acm_certificate.cert.status
  description = "Status of the certificate"
}