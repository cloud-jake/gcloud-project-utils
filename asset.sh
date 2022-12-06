# cloudasset.googleapis.com

  gcloud asset search-all-iam-policies \
  --scope=organizations/584223828499 \
  --query='policy:autoapprove.com' \
  --asset-types='cloudresourcemanager.*' \
  --page-size=50 \
  --flatten='policy.bindings[].members[]' \
  --format='csv(resource, policy.bindings.role, policy.bindings.members)' | grep kinandcarta.com
