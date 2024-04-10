locals {
  group_names = {
    frontend_user_group = { name = "${var.frontend_user_group_name}" }
    devops_user_group   = { name = "${var.devops_user_group_name}" }
    backend_user_group  = { name = "${var.backend_user_group_name}" }
    qa_user_group       = { name = "${var.qa_user_group_name}" }
    admin_user_group    = { name = "${var.admin_user_group_name}" }
  }
}