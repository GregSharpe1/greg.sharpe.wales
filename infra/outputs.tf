output sharpe_wales_nameserver {
  value = aws_route53_zone.sharpe_wales.name_servers
}

output sharpe_cymru_nameserver {
  value = aws_route53_zone.sharpe_cymru.name_servers
}