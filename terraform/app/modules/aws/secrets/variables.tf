variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub token for token rotation"
  validation {
    condition     = can(regex("^gh[pousr]_[A-Za-z0-9]{36}$", var.github_token))
    error_message = "The github_token must be a valid GitHub token format."
  }
}