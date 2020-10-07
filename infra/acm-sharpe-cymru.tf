resource aws_acm_certificate greg_sharpe_cymru {
  provider = aws.us-east-1

  domain_name       = "greg.sharpe.cymru"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Environment" = "Production"
    "Email"       = "awsprod+me@gregsharpe.co.uk"
    "Account"     = "gregsharpe-prod"
    "Cost"        = "0"
  }
}

resource "aws_route53_record" "greg_sharpe_cymru_cert_validation" {
  provider = aws.us-east-1

  zone_id = aws_route53_zone.sharpe_cymru.id
  name    = aws_acm_certificate.greg_sharpe_cymru.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.greg_sharpe_cymru.domain_validation_options[0].resource_record_type
  ttl     = 60

  records = [
    aws_acm_certificate.greg_sharpe_cymru.domain_validation_options[0].resource_record_value
  ]

}
