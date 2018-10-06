variable "bucket_name" {
  description = "S3 Bucket name for the Terraform state store"
  type        = "string"
}

variable "table_name" {
  description = "DynamoDB table name for the Terraform state lock"
  type        = "string"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = "map"
  default     = {}
}
