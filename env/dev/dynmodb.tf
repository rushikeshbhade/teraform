module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"
  version  = " 5.5.0"
  name     = "file-metadata"
  hash_key = "file_name"

  attributes = [
    {
      name = "file_name"
      type = "S"
    }
  ]

}
