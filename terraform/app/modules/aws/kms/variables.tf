variable "tags" {
  description = "Tags to be attached to the KMS Key"
  type        = map(any)
}

variable "codepipeline_role_arn" {
  description = "ARN of the codepipeline IAM role"
  type        = string
}

variable "kms_condition_account_value" {
  description = "Value for sid EnableRootAccessAndPreventPermissionDelegation condition"
  type        = string
}