terraform {
  required_version = ">= 0.11.8"  # Older versions not tested
}

# S3 Bucket
resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = "${merge(var.tags, map("Name", "${var.bucket_name}"))}"
}

# DynamoDB Table
resource "aws_dynamodb_table" "this" {
  name = "${var.table_name}"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = "${merge(var.tags, map("Name", "${var.table_name}"))}"

  depends_on = ["aws_s3_bucket.this"]
}
