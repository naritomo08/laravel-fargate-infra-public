resource "aws_s3_bucket" "env_file" {
  bucket = "terraform-state-${local.name_prefix}-${local.service_name}-env-file"
  force_destroy = true

  tags = {
    Name = "terraform-state-${local.name_prefix}-${local.service_name}-env-file"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "env_file" {
  bucket = "terraform-state-${local.name_prefix}-${local.service_name}-env-file"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
