terraform {
  backend "s3" {
    bucket         = "gregsharpe-tfstate"
    key            = "greg.sharpe.wales/terraform.state"
    dynamodb_table = "gregsharpe-tfstate-lock"
    region         = "eu-west-1"
  }
}
