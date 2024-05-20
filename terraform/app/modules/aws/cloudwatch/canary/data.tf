data "archive_file" "lambda_canary_zip" {
  type        = "zip"
  output_path = local.zip
  source {
    content  = file("${var.path_to_canary}/heartbeat.py")
    filename = "python/canary.py"
  }
}