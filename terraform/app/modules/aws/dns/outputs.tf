output "id" {
  value       = aws_acm_certificate.this.id
  description = "ID of ACM Certificate"
}

output "arn" {
  value       = aws_acm_certificate.this.arn
  description = "ARN of ACM Certificate"
}
