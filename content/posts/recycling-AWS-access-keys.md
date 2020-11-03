---
title: "Recycling AWS Access Keys"
tags: ['AWS', 'Automation', 'Scripting', 'Tutorial']
date: 2020-10-07T21:42:05+01:00
draft: false
---

If you're ever in need of an automated way of recycling your AWS access keys, here's a script:
```
#!/bin/bash
# Example usage:
# ./aws-recycle-keys.sh aws+ma@gregsharpe.co.uk my-aws-profile (check within ~/.aws/config)

AWS_USERNAME=$1
AWS_PROFILE=${2:-default}
AWS_REGION=${3:-eu-west-1}

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
NEW_ACCESS_KEY_ID=$(echo "${NEW_ACCESS_KEY}" | jq -r '.AccessKey.AccessKeyId')
NEW_SECRET_ACCESS_KEY=$(echo "${NEW_ACCESS_KEY}" | jq -r '.AccessKey.SecretAccessKey')

echo "New AccessKeyId: $NEW_ACCESS_KEY_ID"
echo "Setting old $CURRENT_ACCESS_KEY to inactive"
AWS_PAGER='' aws iam update-access-key --profile $AWS_PROFILE --access-key-id $CURRENT_ACCESS_KEY --status Inactive --user-name $AWS_USERNAME

echo "Replacing old access keys in ~/.aws/credentials"
aws configure --profile $AWS_PROFILE <<EOM
$NEW_ACCESS_KEY_ID
$NEW_SECRET_ACCESS_KEY
$AWS_REGION
json
EOM

# Eventual consistence
sleep 5

echo "Removing $CURRENT_ACCESS_KEY from user: $AWS_USERNAME"
AWS_ACCESS_KEY_ID=$NEW_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$NEW_SECRET_ACCESS_KEY AWS_PAGER='' aws iam delete-access-key --profile $AWS_PROFILE --access-key-id $CURRENT_ACCESS_KEY --user-name $AWS_USERNAME

echo "Keys rotated..."
```

call the script (after `chmod +x filename.sh`) with the user account name you wish to recycle.

i have this aliased to `personal-aws-rotate` which is run often.
