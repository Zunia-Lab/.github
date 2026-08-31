#!/usr/bin/env bash
set -euo pipefail

ORG="Zunia-Lab"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

REPOS=(
  ".github"
  "zunia-brand"
  "zunia-chain-registry"
  "zunia-docs"
  "zunia-website"
  "zunia-extension"
  "zunia-mobile"
  "zunia-dashboard"
  "zunia-ui"
  "zunia-sdk"
  "zunia-core"
  "zunia-backend"
  "zunia-e2e"
  "zunia-infra"
  "zunia-indexer"
)
# Create zunia-security privately: gh repo create Zunia-Lab/zunia-security --private --source=./zunia-security

if ! gh api "orgs/${ORG}" &>/dev/null; then
  echo "Org ${ORG} missing. Run ./scripts/setup-org.sh first (create org in GitHub UI)."
  exit 1
fi

for repo in "${REPOS[@]}"; do
  dir="${ROOT}/${repo}"
  if [[ ! -d "${dir}" ]]; then
    echo "Skipping ${repo}: directory missing"
    continue
  fi
  echo "==> ${ORG}/${repo}"
  cd "${dir}"
  if [[ ! -d .git ]]; then
    git init -b main
    git add -A
    git commit -m "Initial commit"
  fi
  if ! git remote get-url origin &>/dev/null; then
    gh repo create "${ORG}/${repo}" --public --source=. --remote=origin --push
  else
    # Rebind origin for fork clone if still pointing at upstream
    current="$(git remote get-url origin)"
    if [[ "${current}" == *"chainapsis"* ]]; then
      git remote rename origin upstream 2>/dev/null || true
      gh repo create "${ORG}/${repo}" --public --source=. --remote=origin --push || {
        git remote add origin "https://github.com/${ORG}/${repo}.git"
        git push -u origin main
      }
    else
      git push -u origin HEAD:main
    fi
  fi
  # Topics (best-effort)
  case "${repo}" in
    zunia-website) gh repo edit "${ORG}/${repo}" --add-topic cosmos --add-topic wallet --add-topic ibc --add-topic nextjs 2>/dev/null || true ;;
    zunia-extension) gh repo edit "${ORG}/${repo}" --add-topic browser-extension --add-topic cosmos --add-topic wallet 2>/dev/null || true ;;
    zunia-mobile) gh repo edit "${ORG}/${repo}" --add-topic flutter --add-topic android --add-topic ios --add-topic cosmos-wallet 2>/dev/null || true ;;
    zunia-chain-registry) gh repo edit "${ORG}/${repo}" --add-topic cosmos --add-topic ibc --add-topic chain-registry --add-topic zunia 2>/dev/null || true ;;
    zunia-docs) gh repo edit "${ORG}/${repo}" --add-topic docusaurus --add-topic documentation --add-topic cosmos 2>/dev/null || true ;;
    zunia-brand) gh repo edit "${ORG}/${repo}" --add-topic brand --add-topic design --add-topic zunia 2>/dev/null || true ;;
    zunia-dashboard) gh repo edit "${ORG}/${repo}" --add-topic nextjs --add-topic cosmos --add-topic wallet 2>/dev/null || true ;;
    zunia-ui) gh repo edit "${ORG}/${repo}" --add-topic design-system --add-topic react --add-topic zunia 2>/dev/null || true ;;
    zunia-sdk) gh repo edit "${ORG}/${repo}" --add-topic sdk --add-topic typescript --add-topic flutter --add-topic cosmos --add-topic wallet 2>/dev/null || true ;;
    zunia-core) gh repo edit "${ORG}/${repo}" --add-topic wallet --add-topic cryptography --add-topic cosmos --add-topic typescript 2>/dev/null || true ;;
    zunia-backend) gh repo edit "${ORG}/${repo}" --add-topic api --add-topic notifications --add-topic cosmos 2>/dev/null || true ;;
    zunia-e2e) gh repo edit "${ORG}/${repo}" --add-topic e2e --add-topic playwright --add-topic testing 2>/dev/null || true ;;
    zunia-infra) gh repo edit "${ORG}/${repo}" --add-topic infrastructure --add-topic pulumi 2>/dev/null || true ;;
    zunia-indexer) gh repo edit "${ORG}/${repo}" --add-topic indexer --add-topic cosmos 2>/dev/null || true ;;
  esac
done

echo "Done. Org: https://github.com/${ORG}"
