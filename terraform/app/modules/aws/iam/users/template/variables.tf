variable "user_name" {
  description = "Name of the User"
  type        = string
}

variable "user_path" {
  description = "Path of the User"
  type        = string
}

variable "group_membership_name" {
  description = "Group Membership Name for the Group"
  type        = string
}

variable "user_group_name" {
  description = "Name of the Users Group"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the resource"
  type        = map(any)
}