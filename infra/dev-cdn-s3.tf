module "dev_greg_sharpe_wales" {
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
  cached_methods           = ["GET", "HEAD", "OPTIONS"]
  cors_allowed_headers     = ["*"]
  cors_allowed_origins     = ["*"]

  tags = {
    "Environment" = "Development"
    "Email"       = "awsdev+me@gregsharpe.co.uk"
    "Account"     = "gregsharpe-dev"
    "Cost"        = "0"
  }
}

module "dev_greg_sharpe_cymru" {
  source                   = "cloudposse/cloudfront-s3-cdn/aws"
  version                  = "0.23.1"
  namespace                = "dev-greg.sharpe.cymru"
  stage                    = "dev"
  name                     = "s3"
  aliases                  = ["dev-greg.sharpe.cymru"]
  parent_zone_id           = aws_route53_zone.sharpe_cymru.id
  index_document           = "index.html"
  logging_enabled          = "false"
  acm_certificate_arn      = aws_acm_certificate.dev_greg_sharpe_cymru.arn
  minimum_protocol_version = "TLSv1.2_2018"
  price_class              = "PriceClass_100"
  cached_methods           = ["GET", "HEAD", "OPTIONS"]
  cors_allowed_headers     = ["*"]
  cors_allowed_origins     = ["*"]

  tags = {
    "Environment" = "Development"
    "Email"       = "awsdev+me@gregsharpe.co.uk"
    "Account"     = "gregsharpe-dev"
    "Cost"        = "0"
  }
}