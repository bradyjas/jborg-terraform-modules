# terraform-s3-backend

A Terraform module to create a S3 state store and DynamoDB lock table.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| `bucket_name` | S3 Bucket name for the Terraform state store | string | - | Yes |
| `table_name` | DynamoDB table name for the Terraform state lock | string | - | Yes |
| `tags` | A map of tags to add to all resources | map | `{}` | No |


## Outputs

| Name | Description |
|------|-------------|
| `bucket_name` | S3 Bucket name for the Terraform state store |
| `table_name` | DynamoDB table name for the Terraform state lock |


## Example Usage

```hcl
module "terraform-s3-backend" {
  source = "./terraform-s3-backend"

  bucket_name = "my-terraform-state-store"
  table_name  = "my-terraform-lock-table"
  tags = {
    Owner       = "Cloud Operations"
    CreatedBy   = "Terraform"
    Environment = "prod"
  }
}
```
