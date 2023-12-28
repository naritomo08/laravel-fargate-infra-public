resource "aws_s3_bucket" "this" {
  bucket = "terraform-state-${local.name_prefix}-alb-log"
  force_destroy = true

  tags = {
    Name = "terraform-state-${local.name_prefix}-alb-log"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = "terraform-state-${local.name_prefix}-alb-log"
  rule {
    status                                 = "Enabled"
    id                                     = "s3-acl-lifecycle"
    expiration {
      days                         = 30
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = "terraform-state-${local.name_prefix}-alb-log"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_elb_service_account.current.id}:root"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "delivery.logs.amazonaws.com"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.this.id}/*",
          "Condition" : {
            "StringEquals" : {
              "s3:x-amz-acl" : "bucket-owner-full-control"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "delivery.logs.amazonaws.com"
          },
          "Action" : "s3:GetBucketAcl",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.this.id}"
        }
      ]
    }
  )
}
