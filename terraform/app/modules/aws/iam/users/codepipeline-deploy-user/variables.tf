variable "policy_arns" {
  type        = map(map(string))
  description = "Set of policies to attach to Role"
}

variable "tags" {
  description = "Tags to be attached to the resource"
  type        = map(any)
}