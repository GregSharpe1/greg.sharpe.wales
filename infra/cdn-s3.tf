module "cloudfront-s3-cdn" {
  source                   = "cloudposse/cloudfront-s3-cdn/aws"
  version                  = "0.23.1"
  namespace                = "dev-greg.sharpe.wales"
  stage                    = "dev"
  name                     = "s3"
  aliases                  = ["dev-greg.sharpe.wales"]
  parent_zone_id           = aws_route53_zone.sharpe_wales.id
  index_document           = "index.html"
  logging_enabled          = "false"
  acm_certificate_arn      = aws_acm_certificate.dev_greg_sharpe_wales.arn
  minimum_protocol_version = "TLSv1.2_2018"
  price_class              = "PriceClass_100"

  tags = {
    "Environment" = "Development"
    "Email"       = "awsdev+me@gregsharpe.co.uk"
    "Account"     = "gregsharpe-dev"
    "Cost"        = "0"
  }
}
