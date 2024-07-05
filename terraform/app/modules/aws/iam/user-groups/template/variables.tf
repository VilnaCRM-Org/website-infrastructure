variable "group_name" {
  description = "Unique name for Users Group"
  type        = string
}

variable "group_path" {
  description = "Unique path for Users Group"
  type        = string
}

variable "policy_arns" {
  type        = map(map(string))
  description = "Set of policies to attach to Role"
}