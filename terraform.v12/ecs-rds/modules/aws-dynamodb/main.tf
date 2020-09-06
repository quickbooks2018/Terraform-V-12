resource "aws_dynamodb_table" "dynamodb-table" {
  name           = var.dynamoTable_Name
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "Path"
  range_key      = "Key"
  attribute   {
      name = "Path"
      type = "S"
    }
    attribute {
      name = "Key"
      type = "S"
    }

  tags = {
    Name        = var.tag_Name
    Environment = var.tag_Environment
  }
}