---
title: "AWS Aliases"
date: 2020-10-08T20:54:27+01:00
draft: false
---

some handy, commonly used aws commands I use :)

```
#!/bin/bash

aws-who-am-i() {
  # aws-who-am-i

  aws sts get-caller-identity --output text "${@}"
}

aws-eks-update-config() {
  # aws-update-eks-config eu-west-1 my-aws-kube-cluster

  aws eks --region "${1}" update-kubeconfig --name "${2}" --alias "${2}"
}

aws-ec2-running-instances() {
 aws ec2 describe-instances \
    --region "${1}" \
    --filter Name=instance-state-name,Values=running \
    --output table \
    --query 'Reservations[].Instances[].{ID: InstanceId,Hostname: PublicDnsName,Name: Tags[?Key==`Name`].Value | [0],Type: InstanceType, Platform: Platform || `Linux`}'
}

aws-ec2-list-sgs() {
 aws ec2 describe-security-groups --region "${1}" --query "SecurityGroups[].[GroupId, GroupName]" --output table
}

aws-ec2-get-ebs() {
  # aws-get-ebs eu-west-2
  aws ec2 describe-volumes --filters Name=status,Values=available --region "${1}" | jq --raw-output ".Volumes[].VolumeId"
}

aws-ec2-cleanup-ebs() {
  # aws-cleanup-ebs eu-west-2
  aws ec2 describe-volumes --filters Name=status,Values=available --region "${1}" | jq --raw-output ".Volumes[].VolumeId" | while read VOLUME_ID; do \
        aws ec2 delete-volume --volume-id $VOLUME_ID --region "${1}"
  done
}

aws-eks-list-clusters() {
  # aws-list-clusters us-west-1
  aws eks list-clusters --region "${1}" \
	  | jq -r '.clusters[]'
}

aws-ecr-login() {
  # aws-ecr-login eu-west-1

  endpoint=$(aws ecr get-authorization-token --query 'authorizationData[].proxyEndpoint' --region "${1}" --output text)
  passwd=$(aws ecr get-authorization-token --query 'authorizationData[].authorizationToken' --region "${1}" --output text | base64 --decode | cut -d: -f2)
  docker login -u AWS -p $passwd $endpoint

}

aws-rotate-access-keys() {
  # aws-rotate-access-keys user-account-name aws-profile
  AWS_USERNAME=$1
  AWS_PROFILE=${2:-default}

  echo "Using $AWS_PROFILE..."
  CURRENT_ACCESS_KEYS=$(aws iam list-access-keys --profile $AWS_PROFILE --user-name ${AWS_USERNAME})

  # Test amount of keys
  if [[ $(echo $CURRENT_ACCESS_KEYS | jq -r '.AccessKeyMetadata | length') -gt 1 ]]; then
    echo "You've got multiple Access keys within your account. Please remove the unused key"
    exit 1
  fi

  CURRENT_ACCESS_KEY=$(echo $CURRENT_ACCESS_KEYS | jq -r '.AccessKeyMetadata[].AccessKeyId')
  echo "Current access list $CURRENT_ACCESS_KEY"

  echo "Creating new AWS Access key..."
  NEW_ACCESS_KEY=$(aws iam create-access-key --profile $AWS_PROFILE --user-name $AWS_USERNAME)
  echo $NEW_ACCESS_KEY
  NEW_ACCESS_KEY_ID=$(echo "${NEW_ACCESS_KEY}" | jq -r '.AccessKey.AccessKeyId')
  NEW_SECRET_ACCESS_KEY=$(echo "${NEW_ACCESS_KEY}" | jq -r '.AccessKey.SecretAccessKey')
  echo "New AccessKeyId: $NEW_ACCESS_KEY_ID"

  echo "Setting old $CURRENT_ACCESS_KEY to inactive"
  AWS_PAGER='' aws iam update-access-key --profile $AWS_PROFILE --access-key-id $CURRENT_ACCESS_KEY --status Inactive --user-name $AWS_USERNAME

  echo "Replacing old access keys in ~/.aws/credentials"
  aws configure --profile $AWS_PROFILE <<EOM
$NEW_ACCESS_KEY_ID
$NEW_SECRET_ACCESS_KEY
eu-west-1
json
EOM
  echo "Keys rotated..."
}
```

i use alaises loads, which live in my home directory under `~/.alias` then inside my `.zshrc` I have the following to make sure they're sourced.

```
# source alises
for f in $(find $HOME/.alias/*.alias -type f); do source $f; done
```
