#!/usr/bin/env bash
set -euo pipefail

ORG="Zunia-Lab"
ADMIN="${GITHUB_USER:-danbaruka}"

if ! gh api "orgs/${ORG}" &>/dev/null; then
  echo "Organization '${ORG}' not found or no access."
  exit 1
fi

echo "Updating org profile..."
gh api "orgs/${ORG}" -X PATCH \
  -f name="Zunia Lab" \
  -f description="Multi-chain Cosmos wallet. Browser extension, mobile app, IBC-native. Built by Zunia Lab." \
  -f company="Zunia Lab" \
  -f blog="https://zunialab.com" \
  -f email="hello@zunialab.com" \
  -f location="Remote" \
  -F default_repository_permission=read \
  -F members_can_create_repositories=false

# Public membership for profile visitors
gh api -X PUT "orgs/${ORG}/public_members/${ADMIN}" 2>/dev/null || true

echo "Organization ${ORG} configured: https://github.com/${ORG}"
echo "Upload logo: https://github.com/organizations/${ORG}/settings/profile"
echo "Use: zunia-brand/png/icons/zunia-icon-cobalt-512.png"
