resource aws_route53_zone sharpe_wales {
  name = "sharpe.wales"

  tags = {
    "Environment" = "Production"
    "Email"       = "awsproduction+me@gregsharpe.co.uk"
    "Account"     = "gregsharpe-production"
    "Cost"        = "0.5" # In dollars
  }
}


resource aws_route53_zone sharpe_cymru {
  name = "sharpe.cymru"

  tags = {
    "Environment" = "Production"
    "Email"       = "awsproduction+me@gregsharpe.co.uk"
    "Account"     = "gregsharpe-production"
    "Cost"        = "0.5"
  }
}