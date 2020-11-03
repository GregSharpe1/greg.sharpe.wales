---
title: "Sharing Screenshots"
tags: ['AWS', 'Tech', 'Terraform', 'Tutorial', 'Scripting', 'Linux']
date: 2020-10-13T19:02:13+01:00
draft: false
---

## Sharing Screenshots

Something I'm quite proud of, is my screenshotting tool. Everytime I take a screenshot on my Linux machine it automatically gets uploaded to an S3 bucket, which is fronted with Amazon's Web Services' CDN service and a link to that publically available screenshot is in my clipboard.

[Here](https://screenshot.gregsharpe.co.uk/2020-10-13_19-14-32_screenshot.png) is an example.

## Why?

* Sharing images is easier. No need to upload, then download the image, find it within local machine.
* Screenshots across multiple machines.

## Infrastructure required

Here's a list of AWS services:

* AWS S3
* AWS CDN
* AWS IAM
* AWS ACM
* AWS Route53 (although, anywhere that controlls your domain will do)

## Terraform setup

I like to use public Terraform modules as much as possible, and have used [cloudposse](https://github.com/cloudposse) quite a few times for various things, and tend to be my go to Terraform module provider (after AWS official modules of course).

### SSL Certificate

One easy way to create free SSL certificates is to use, [Amazon's ACM](https://aws.amazon.com/certificate-manager/) service. This does come with its drawbacks though, like you can only use AWS services with the certificate, but this will be used in combination with AWS CDN which is fully supported.

```
resource aws_acm_certificate root_gregsharpe {
  domain_name               = "gregsharpe.co.uk"
  subject_alternative_names = ["*.gregsharpe.co.uk"]
  validation_method         = "EMAIL"

  lifecycle {
    create_before_destroy = true
  }
}
```

* Make sure to create this resource within `us-east-1` region, as using an ACM certificate with CDN is only supported within `us-east-1.`

### CDN, S3 bucket

Using the aws [aws-cloudfront-s3-cdn](https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn) module, creating a CDN:

```
module screenshot {
  source                   = "cloudposse/cloudfront-s3-cdn/aws"
  version                  = "0.35.0"
  namespace                = "screenshot"
  stage                    = "prod"
  name                     = "s3"
  aliases                  = ["screenshot.gregsharpe.co.uk"]
  index_document           = "index.html"
  logging_enabled          = "false"
  acm_certificate_arn      = aws_acm_certificate.root_gregsharpe.arn
  minimum_protocol_version = "TLSv1.2_2018"
  price_class              = "PriceClass_100"
  cached_methods           = ["GET", "HEAD", "OPTIONS"]
  cors_allowed_headers     = ["*"]
  cors_allowed_origins     = ["*"]
}

```

### (Optional) Route53

If using Amazon Web Services' Route53 service, then the following Terraform should allow your to create the required CNAME to point at the cloudfront distrobution.

```
resource aws_route53_record screenshot_cname {
  zone_id = "EXMAPLEZONEID" # My gregsharpe.co.uk hosted zone id
  name    = "screenshot.gregsharpe.co.uk"
  type    = "CNAME"
  ttl     = "300"
  records = [module.screenshot.cf_domain_name]
}
```

Otherwise, add
```
output cf_domain_name {
  value = module.screenshot.cf_domain_name
}
```

to your `main.tf` file and add follow up with your domain manager to add screenshot.yourdomain.tld to the output (CNAME'd)

### (Recommended) Create an AWS User

Creating a profile within on your machine that is only able to upload files to that given bucket is something I'd higly recommend. Here's how:

```
resource aws_iam_policy screenshot {
  name        = "screenshot-uploader"
  description = "screenshot.gregsharpe.co.uk application user permissions"

  policy = data.aws_iam_policy_document.screenshot.json
}

data aws_iam_policy_document screenshot {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      module.screenshot.s3_bucket_arn,
      "${module.screenshot.s3_bucket_arn}/*"
    ]
  }
}

resource aws_iam_user screenshot {
  name = "screenshot-uploader"
}

resource aws_iam_user_policy_attachment screenshot {
  user       = aws_iam_user.screenshot.name
  policy_arn = aws_iam_policy.screenshot.arn
}
```

After this IAM User and policy is created within Terraform create the aws profile locally adding the [users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) access key and secret access key. Making sure to match the profile name with the profile name used within the script below.

## (Optional) Linux setup

Without going into too much detail, on my Linux machine a script is run everytime I take a screenshot which looks like this:

```
#!/bin/bash

AWS_profile=screenshot-uploader
BUCKET_NAME=screenshot-prod-s3-origin

# Find the latest file in the screenshots directory
latest_screenshot=$(ls -Art /home/greg/pictures/screenshots | tail -n 1)
backup_file_name=/home/greg/pictures/screenshots/${latest_screenshot}

echo 'Sending screen to S3'
# Send the file to the S3 bucket
aws --profile "${AWS_profile}" s3 cp "${backup_file_name}" s3://"${BUCKET_NAME}"/

# Pipe the new link in clipboard
echo 'https://screenshot.gregsharpe.co.uk/'${latest_screenshot} | xclip -selection "clipboard" -i

# Send the notification to the dunst notifier
notify-send $(echo 'https://screenshot.gregsharpe.co.uk/'${latest_screenshot})
```

The above script, grabs the latest screenshot within my given screenshots directory and using the [awscli](https://aws.amazon.com/cli/) copies a the file to the S3 bucket and places the link to that object in my pastebin.

### Further documentation

* All of the Terraform used above is hosted [here](https://github.com/gregsharpe-infra/screenshot)
* The cloudposse Terraform [module](https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn).

