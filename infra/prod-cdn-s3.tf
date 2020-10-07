module "greg_sharpe_wales" {
  source                   = "cloudposse/cloudfront-s3-cdn/aws"
  version                  = "0.23.1"
  namespace                = "greg.sharpe.wales"
  stage                    = "prod"
  name                     = "s3"
  aliases                  = ["greg.sharpe.wales"]
  parent_zone_id           = aws_route53_zone.sharpe_wales.id
  index_document           = "index.html"
  logging_enabled          = "false"
  acm_certificate_arn      = aws_acm_certificate.greg_sharpe_wales.arn
  minimum_protocol_version = "TLSv1.2_2018"
  price_class              = "PriceClass_100"
  cached_methods           = ["GET", "HEAD", "OPTIONS"]
  cors_allowed_headers     = ["*"]
  cors_allowed_origins     = ["*"]
  website_enabled = true
  routing_rules = <<EOF
  [{
    "Condition": {
      "KeyPrefixEquals": "/"
    },
    "Redirect": {
      "ReplaceKeyWith": "index.html"
    }
  }]
  EOF

  tags = {
    "Environment" = "Production"
    "Email"       = "awsprod+me@gregsharpe.co.uk"
    "Account"     = "gregsharpe-prod"
    "Cost"        = "0"
  }
}

module "greg_sharpe_cymru" {
  source                   = "cloudposse/cloudfront-s3-cdn/aws"
  version                  = "0.23.1"
  namespace                = "greg.sharpe.cymru"
  stage                    = "prod"
  name                     = "s3"
  aliases                  = ["greg.sharpe.cymru"]
  parent_zone_id           = aws_route53_zone.sharpe_cymru.id
  index_document           = "index.html"
  logging_enabled          = "false"
  acm_certificate_arn      = aws_acm_certificate.greg_sharpe_cymru.arn
  minimum_protocol_version = "TLSv1.2_2018"
  price_class              = "PriceClass_100"
  cached_methods           = ["GET", "HEAD", "OPTIONS"]
  cors_allowed_headers     = ["*"]
  cors_allowed_origins     = ["*"]
  website_enabled = true
  routing_rules = <<EOF
  [{
    "Condition": {
      "KeyPrefixEquals": "/"
    },
    "Redirect": {
      "ReplaceKeyWith": "index.html"
    }
  }]
  EOF

  tags = {
    "Environment" = "Production"
    "Email"       = "awsprod+me@gregsharpe.co.uk"
    "Account"     = "gregsharpe-prod"
    "Cost"        = "0"
  }
}
