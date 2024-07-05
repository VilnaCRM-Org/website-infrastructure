variable "user_name" {
  description = "Name of the User"
  type        = string
}

variable "user_path" {
  description = "Path of the User"
  type        = string
}

variable "groups" {
  description = "Groups in which user will we assigned"
  type        = map(map(string))
}

variable "tags" {
  description = "Tags to be attached to the resource"
  type        = map(any)
}