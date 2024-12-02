variable "policy_name" {
  description = "Name of the IAM policy for GitHub token access."
  type        = string
  default     = "GitHubTokenSecretsAccessPolicy"
}