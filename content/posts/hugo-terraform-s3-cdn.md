---
title: "Hugo Terraform S3 Cdn"
tags: ['AWS', 'Terraform', 'Tech', 'Infrastructure', 'Tutorial']
date: 2020-10-07T22:59:26+01:00
draft: false
---

# Introduction

Amazon Web Services' S3, CDN, Route53 and ACM are a great way to create and host a static website for _basically_ free. I've been running this site and a variety of static blogs ([gregsharpe.co.uk](https://gregsharpe.co.uk)) using these services for a few years now. Not once have the monthly costs gone over $0.51, and the $0.50 is a for the Route53 public hosted zone. (Disclaimer, my little blog sites get maybe 10/20 views per day)

## Terraform

Combine the easy to use services above with Terraform, and everything becomes a little easier. Here's a working example of everything you need.

### Route53

```
resource aws_route53_zone sharpe_wales {
  name = "sharpe.wales"

  tags = {
    "Environment" = "Production"
    "Email"       = "awsproduction+me@gregsharpe.co.uk"
    "Account"     = "gregsharpe-production"
  }
}
```

### Cloudposse Terraform module

```
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
  }
}
```

### Amazon Managed Certificate

The AWS certificate has to be created within the `us-east-1` region, when working with CloudFront.

```
provider aws {
  region = "us-east-1"
  alias  = "us-east-1"
}

resource aws_acm_certificate greg_sharpe_wales {
  provider = aws.us-east-1

  domain_name       = "greg.sharpe.wales"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Environment" = "Production"
    "Email"       = "awsprod+me@gregsharpe.co.uk"
    "Account"     = "gregsharpe-prod"
  }
}

resource "aws_route53_record" "greg_sharpe_wales_cert_validation" {
  provider = aws.us-east-1

  zone_id = aws_route53_zone.sharpe_wales.id
  name    = aws_acm_certificate.greg_sharpe_wales.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.greg_sharpe_wales.domain_validation_options[0].resource_record_type
  ttl     = 60

  records = [
    aws_acm_certificate.greg_sharpe_wales.domain_validation_options[0].resource_record_value
  ]

}
```

## The End

Check out a working example [here](https://github.com/GregSharpe1/greg.sharpe.wales/tree/master/infra).
