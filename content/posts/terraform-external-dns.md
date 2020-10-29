---
title: "Terraform, Kuberentes and External DNS"
tags: ['AWS', 'Terraform', 'Kubernetes', 'External-DNS', 'Help', 'Tech', 'Infrastructure', 'Tutorial']
date: 2020-10-29T11:25:00Z
draft: true
---

# Introduction

if you're like me, and have your Kubernetes/EKS cluster being built in AWS with Terraform and use Route53 you're probably running [external-dns](https://github.com/kubernetes-sigs/external-dns) (if you're not, I highly recommend it, if only for it's ease of use).

## Problems

I've recently discovered an issue with using this setup when attempting to destroy. External-DNS creates Route53 records within your Route53 hosted zone if in AWS. The environment you have created using Terraform in AWS now doesn't have any state of these records so the Route53 zone cannot be deleted by Terraform.

## Solution

One solution I have come up with is to use `local-exec` on destroy within the Route53 resource as follows:

```
resource aws_route53_zone hosted_zone {
  name = my-hosted-zone.com

  tags = map(
    "Name", "my-hosted-zone.com",
    "Email", "me@my-hosted-zone.com"
  )

  // Route53 records are now controlled via External-DNS, to enable the deletion of the environment we require the Route53 hosted-zone to be clear before destorying. Here's a little hacky way of doing so.
  provisioner local-exec {
    when    = destroy
    command = <<EOT
    aws route53 list-resource-record-sets \
      --hosted-zone-id "${self.zone_id}" |
    jq -c '.ResourceRecordSets[]' |
    while read -r resourcerecordset; do
      read -r name type <<<$(echo $(jq -r '.Name,.Type' <<<"$resourcerecordset"))
      if [ $type != "NS" -a $type != "SOA" ]; then
        aws route53 change-resource-record-sets \
          --hosted-zone-id "${self.zone_id}" \
          --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":
              '"$resourcerecordset"'
            }]}' \
          --output text --query 'ChangeInfo.Id'
      fi
    done
    EOT
  }
}
```

The above will clear down the hosted zone of all records before removing the resource. **Be warned** there is no way of restoring the records once deleted, so triple check your Terraform output.
