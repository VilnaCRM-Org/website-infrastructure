variable "website_user_group_name" {
  description = "Name of the Users Group"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the resource"
  type        = map(any)
}